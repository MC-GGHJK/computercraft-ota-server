import os
import json
import hashlib

# Configuration
OS_DIR = "OS" # The local directory containing the OS files
OUTPUT_FILE = "content.json"
BASE_URL = "https://raw.githubusercontent.com/MC-GGHJK/computercraft-ota-server/refs/heads/main/OS/"

def calculate_sha256(file_path):
    sha256_hash = hashlib.sha256()
    with open(file_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def generate_manifest():
    if not os.path.isdir(OS_DIR):
        print(f"Error: Directory '{OS_DIR}' not found.")
        return

    content = []

    print(f"Scanning directory: {OS_DIR}")

    for dirpath, dirnames, filenames in os.walk(OS_DIR):
        # Filter out hidden directories
        dirnames[:] = [d for d in dirnames if not d.startswith('.')]

        for filename in filenames:
            full_path = os.path.join(dirpath, filename)

            # Create relative path from the OS_DIR
            # This ensures paths in JSON are like "startup.lua", "lib/api.lua" etc.
            rel_path = os.path.relpath(full_path, OS_DIR)

            # Normalize path separators to forward slashes
            rel_path_unix = rel_path.replace(os.path.sep, '/')

            # Construct the full download URL
            if BASE_URL.endswith('/'):
                download_url = BASE_URL + rel_path_unix
            else:
                download_url = BASE_URL + '/' + rel_path_unix

            file_hash = calculate_sha256(full_path)

            content.append({
                "path": rel_path_unix,
                "url": download_url,
                "sha256": file_hash
            })

    # Write the manifest to the root directory (parent of OS_DIR)
    with open(OUTPUT_FILE, "w") as f:
        json.dump(content, f, indent=4)

    print(f"Generated {OUTPUT_FILE} with {len(content)} files.")

if __name__ == "__main__":
    generate_manifest()
