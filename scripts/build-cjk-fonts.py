# Builds the embedded Chinese fonts.
#
# 1. Subsets each Source Han variable font to the GB2312 coverage list.
# 2. Instances it at the single weight the desktop UI uses.
# 3. Compresses the glyphs vertically by 7.5% so Source Han's tall, thin
#    letterforms sit closer to the system CJK font's optical height at small
#    UI sizes. Horizontal advances and widths are untouched.
# 4. Writes compact WOFF2 files into assets/fonts.
#
# Requires Python with fonttools and brotli:
#   python -m pip install fonttools brotli

from io import BytesIO
from pathlib import Path
import sys

from fontTools.subset import Options, Subsetter
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.t2CharStringPen import T2CharStringPen

ROOT = Path(__file__).resolve().parent.parent
REPO = ROOT.parent
SOURCE = REPO / "source"
OUT_DIR = ROOT / "assets" / "fonts"
UNICODES = ROOT / "assets" / "gb2312.txt"

SCALE_Y = 0.925
WEIGHTS = (450,)

FONTS = (
    {
        "input": SOURCE / "SourceHanSansCN-VF.otf",
        "stem": "SourceHanSansCN",
    },
    {
        "input": SOURCE / "SourceHanSerifSC-VF.otf.ttf",
        "stem": "SourceHanSerifSC",
    },
)


def read_unicodes(path: Path) -> set[int]:
    values: set[int] = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line:
            values.add(int(line.removeprefix("U+"), 16))
    return values


def subset(font: TTFont, unicodes: set[int]) -> None:
    options = Options()
    options.name_IDs = ["*"]
    options.name_legacy = True
    options.name_languages = ["*"]
    options.layout_features = ["*"]
    options.notdef_outline = True
    options.recommended_glyphs = True
    subsetter = Subsetter(options=options)
    subsetter.populate(unicodes=unicodes)
    subsetter.subset(font)


def scale_vertical(font: TTFont, scale: float) -> None:
    cff = font["CFF2"].cff
    top = cff.topDictIndex[0]
    cff.desubroutinize()
    glyph_set = font.getGlyphSet()
    char_strings = top.CharStrings

    for name in font.getGlyphOrder():
        pen = T2CharStringPen(None, glyph_set, CFF2=True)
        glyph_set[name].draw(TransformPen(pen, (1, 0, 0, scale, 0, 0)))
        char_strings[name].program = pen.getCharString().program

    hhea = font["hhea"]
    hhea.ascent = round(hhea.ascent * scale)
    hhea.descent = round(hhea.descent * scale)
    hhea.lineGap = round(hhea.lineGap * scale)

    os2 = font["OS/2"]
    for attr in (
        "sTypoAscender",
        "sTypoDescender",
        "sTypoLineGap",
        "usWinAscent",
        "usWinDescent",
        "sxHeight",
        "sCapHeight",
        "yStrikeoutPosition",
        "yStrikeoutSize",
        "ySubscriptYOffset",
        "ySuperscriptYOffset",
    ):
        if hasattr(os2, attr):
            setattr(os2, attr, round(getattr(os2, attr) * scale))

    head = font["head"]
    head.yMin = round(head.yMin * scale)
    head.yMax = round(head.yMax * scale)

    for table in ("VORG", "VVAR", "vhea", "vmtx", "HVAR", "fvar", "avar", "STAT"):
        if table in font:
            del font[table]


def main() -> int:
    unicodes = read_unicodes(UNICODES)
    print(f"coverage: {len(unicodes)} code points")

    for spec in FONTS:
        source = spec["input"]
        if not source.exists():
            print(f"missing input: {source}", file=sys.stderr)
            return 1

        font = TTFont(source)
        subset(font, unicodes)

        buffer = BytesIO()
        font.save(buffer)
        buffer.seek(0)
        print(
            f"{source.name}: {len(font.getGlyphOrder())} glyphs, "
            f"subset {buffer.getbuffer().nbytes / 1024 / 1024:.2f} MiB"
        )

        for weight in WEIGHTS:
            buffer.seek(0)
            instance = TTFont(buffer)
            instance = instantiateVariableFont(
                instance, {"wght": weight}, inplace=False, updateFontNames=False
            )
            scale_vertical(instance, SCALE_Y)

            out = OUT_DIR / f"{spec['stem']}-{weight}.woff2"
            instance.flavor = "woff2"
            instance.save(out)
            print(
                f"wrote {out.name}: {out.stat().st_size / 1024 / 1024:.2f} MiB "
                f"(wght {weight}, y x{SCALE_Y:g})"
            )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
