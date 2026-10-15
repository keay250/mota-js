#!/usr/bin/env python3
"""
Patch missing doors into Map017 (Eze City / 厄泽城) background image:
1. Mercenary Guild Entrance (41, 24) -> 171-Door02.png (96x64) at (1280, 736)
2. Equipment Shop (68, 16) -> 170-Door01.png (32x64) at (2176, 480)
3. Tavern (58, 67) -> 170-Door01.png (32x64) at (1856, 2112)
"""

import os
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BG_PATH = os.path.join(BASE_DIR, "_analysis/_ybfh-mota/project/images/map017_bg.png")
GRAPHICS_DIR = os.path.join(BASE_DIR, "../Graphics/Characters")

def patch_doors():
    if not os.path.exists(BG_PATH):
        raise FileNotFoundError(f"Background image not found: {BG_PATH}")

    bg = Image.open(BG_PATH).convert("RGBA")
    print(f"Loaded background image: {bg.size} ({bg.mode})")

    # 1. Guild Door: 171-Door02.png
    door02_path = os.path.join(GRAPHICS_DIR, "171-Door02.png")
    door02_raw = Image.open(door02_path).convert("RGBA")
    door02_frame = door02_raw.crop((0, 0, 96, 64))
    guild_pos = (40 * 32, 23 * 32) # (1280, 736)
    bg.paste(door02_frame, guild_pos, mask=door02_frame)
    print(f"Pasted Guild Door from {door02_path} at {guild_pos}")

    # 2. Shop Door & Tavern Door: 170-Door01.png
    door01_path = os.path.join(GRAPHICS_DIR, "170-Door01.png")
    door01_raw = Image.open(door01_path).convert("RGBA")
    door01_frame = door01_raw.crop((0, 0, 32, 64))
    
    shop_pos = (68 * 32, 15 * 32) # (2176, 480)
    bg.paste(door01_frame, shop_pos, mask=door01_frame)
    print(f"Pasted Shop Door from {door01_path} at {shop_pos}")

    tavern_pos = (58 * 32, 66 * 32) # (1856, 2112)
    bg.paste(door01_frame, tavern_pos, mask=door01_frame)
    print(f"Pasted Tavern Door from {door01_path} at {tavern_pos}")

    bg.save(BG_PATH, "PNG")
    print(f"Successfully saved patched background to {BG_PATH}")

    # Save verification crops to brain artifact directory if possible
    artifact_dir = "/Users/zt-lin/.gemini/antigravity-cli/brain/48353322-df08-453c-af70-634f832f9ad4"
    if os.path.exists(artifact_dir):
        # Crop Guild around (1280, 736) with margin
        guild_crop = bg.crop((1280 - 64, 736 - 64, 1280 + 96 + 64, 736 + 64 + 64))
        guild_crop.save(os.path.join(artifact_dir, "patched_eze_guild_door.png"))

        shop_crop = bg.crop((2176 - 32, 480 - 32, 2176 + 32 + 32, 480 + 64 + 32))
        shop_crop.save(os.path.join(artifact_dir, "patched_eze_shop_door.png"))

        tavern_crop = bg.crop((1856 - 32, 2112 - 32, 1856 + 32 + 32, 2112 + 64 + 32))
        tavern_crop.save(os.path.join(artifact_dir, "patched_eze_tavern_door.png"))
        print(f"Saved verification crops to {artifact_dir}")

if __name__ == "__main__":
    patch_doors()
