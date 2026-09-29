from pathlib import Path

input_file = Path("healthcare_analytics.csv")
output_file = Path("healthcare_analytics_clean.csv")

# Read the raw CSV bytes
raw = input_file.read_bytes()

# Try UTF-8 first
try:
    text = raw.decode("utf-8")
    print("CSV was already UTF-8.")
except UnicodeDecodeError:
    print("Invalid UTF-8 found. Converting problematic characters...")
    text = raw.decode("latin-1", errors="replace")

# Save as proper UTF-8
output_file.write_text(text, encoding="utf-8", newline="")

print("Done!")
print(f"Clean file created: {output_file}")