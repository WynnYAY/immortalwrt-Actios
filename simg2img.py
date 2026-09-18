#!/usr/bin/env python3
"""Convert Android sparse image to raw image (pure python, no deps)."""
import struct
import sys

def main():
    inp, out = sys.argv[1], sys.argv[2]
    data = open(inp, 'rb').read()
    magic, major, minor, fhs, chs, blksz, total_blks, total_chunks, csum = \
        struct.unpack_from('<IHHHHIIII', data, 0)
    assert magic == 0xED26FF3A, 'not a sparse image: 0x%x' % magic
    print('sparse v%d.%d blk=%d blks=%d chunks=%d' %
          (major, minor, blksz, total_blks, total_chunks))
    outbuf = bytearray(total_blks * blksz)
    pos = fhs
    raw = fill = dc = 0
    for _ in range(total_chunks):
        ctype, _rsv, chunksz, totalsz = struct.unpack_from('<HHII', data, pos)
        pos += chs
        if ctype == 0xCAC1:  # RAW
            outbuf[raw * blksz:(raw + chunksz) * blksz] = \
                data[pos:pos + chunksz * blksz]
            pos += chunksz * blksz
            raw += chunksz
        elif ctype == 0xCAC2:  # FILL
            blk = struct.unpack_from('<I', data, pos)[0].to_bytes(4, 'little') * (blksz // 4)
            pos += 4
            outbuf[raw * blksz:(raw + chunksz) * blksz] = blk * chunksz
            fill += chunksz
        elif ctype == 0xCAC3:  # DONT_CARE
            dc += chunksz
        elif ctype == 0xCAC4:  # CRC32
            pos += 4
        else:
            raise SystemExit('unknown chunk type %d' % ctype)
    print('raw=%d fill=%d dontcare=%d -> %s (%d bytes)' %
          (raw, fill, dc, out, len(outbuf)))
    open(out, 'wb').write(outbuf)

if __name__ == '__main__':
    main()
