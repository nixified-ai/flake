{
  lib,
  python3,
}:
{
  prePatch = ''
        ${python3.interpreter} -c '
    import os
    import re

    filepath = "embeddings_connector.py"
    with open(filepath, "r") as f:
        content = f.read()

    content = content.replace("split_freqs_cis,", "freqs_cis_matrix,")
    content = content.replace("interleaved_freqs_cis,", "")

    old_pattern = r"if self\.split_rope:.*?return cos_freq\.to\(self\.dtype\), sin_freq\.to\(self\.dtype\), self\.split_rope"

    new_code = """if self.split_rope:
                expected_freqs = dim // 2
                current_freqs = freqs.shape[-1]
                pad_size = expected_freqs - current_freqs
                return freqs_cis_matrix(freqs, pad_size, self.split_rope, self.num_attention_heads, self.dtype)
            else:
                return None"""

    content = re.sub(old_pattern, new_code, content, flags=re.DOTALL)

    with open(filepath, "w") as f:
        f.write(content)
    '
  '';
}
