# Naming standards

- Reusable project assets begin with `ONO_`.
- Use ASCII letters, digits, and underscores in asset filenames; avoid spaces.
- Keep every W3D filename and exported object identifier to 15 characters or fewer. The format stores identifiers in a fixed 16-byte field with one byte reserved for the terminator; longer names are silently truncated by the legacy exporter.
- Use a category and a descriptive name: `ONO_Rock_01`, `ONO_Bunker_Small`, `ONO_Texture_Asphalt`.
- Prefer short forms such as `ONO_TestBox`; do not use names such as `ONO_Toolchain_TestBox` that exceed the W3D limit.
- Map packages retain Westwood's required `C&C_` prefix.
- Do not rename stock assets. Record wrappers or derived assets separately and preserve provenance.
- Increment numbered variants with two digits.
