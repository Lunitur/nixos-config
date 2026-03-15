import sys

def parse_cube(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()

    lut_size = 0
    data = []
    
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if line.startswith('LUT_3D_SIZE'):
            lut_size = int(line.split()[1])
            continue
        if line.startswith('TITLE'):
            continue
        if line.startswith('DOMAIN_MIN'):
            continue
        if line.startswith('DOMAIN_MAX'):
            continue
        
        parts = line.split()
        if len(parts) == 3:
            try:
                data.extend([float(p) for p in parts])
            except ValueError:
                continue

    return lut_size, data

def generate_glsl(lut_size, data, profile_name):
    # lut_size is N. data has N*N*N*3 floats.
    
    glsl = []
    glsl.append(f"// Color correction shader for {profile_name}")
    glsl.append(f"// Generated from {profile_name}")
    glsl.append(f"// LUT size: {lut_size}")
    glsl.append("")
    glsl.append(f"#define LUT_SIZE {lut_size}")
    glsl.append(f"#define LUT_SIZE_FLOAT {float(lut_size)}")
    glsl.append("")
    
    glsl.append(f"const float lut[{len(data)}] = float[](")
    
    # Format data
    
    current_line = "    "
    for i, val in enumerate(data):
        current_line += f"{val:.6f}"
        if i < len(data) - 1:
            current_line += ", "
        
        if len(current_line) > 80:
            glsl.append(current_line)
            current_line = "    "
            
    if current_line.strip():
        glsl.append(current_line)
        
    glsl.append(");")
    glsl.append("")
    
    glsl.append("\n// Helper to get value from LUT\nvec3 get_lut_value(int r, int g, int b) {\n    int index = 3 * (r + LUT_SIZE * (g + LUT_SIZE * b));\n    return vec3(lut[index], lut[index+1], lut[index+2]);\n}\n\nvec3 apply_lut(vec3 color) {\n    // Clamp input color to 0.0 - 1.0\n    color = clamp(color, 0.0, 1.0);\n\n    // Map color to LUT coordinate space (0 to LUT_SIZE-1)\n    vec3 coord = color * (LUT_SIZE_FLOAT - 1.0);\n    \n    vec3 index = floor(coord);\n    vec3 fract_part = coord - index;\n    \n    int i0 = int(index.x);\n    int j0 = int(index.y);\n    int k0 = int(index.z);\n    \n    // Clamp indices just in case\n    // (Though clamp on color above should handle it, fp errors might exist)\n    i0 = clamp(i0, 0, LUT_SIZE - 2);\n    j0 = clamp(j0, 0, LUT_SIZE - 2);\n    k0 = clamp(k0, 0, LUT_SIZE - 2);\n    \n    int i1 = i0 + 1;\n    int j1 = j0 + 1;\n    int k1 = k0 + 1;\n    \n    vec3 c000 = get_lut_value(i0, j0, k0);\n    vec3 c100 = get_lut_value(i1, j0, k0);\n    vec3 c010 = get_lut_value(i0, j1, k0);\n    vec3 c110 = get_lut_value(i1, j1, k0);\n    vec3 c001 = get_lut_value(i0, j0, k1);\n    vec3 c101 = get_lut_value(i1, j0, k1);\n    vec3 c011 = get_lut_value(i0, j1, k1);\n    vec3 c111 = get_lut_value(i1, j1, k1);\n    \n    vec3 c00 = mix(c000, c100, fract_part.x);\n    vec3 c10 = mix(c010, c110, fract_part.x);\n    vec3 c01 = mix(c001, c101, fract_part.x);\n    vec3 c11 = mix(c011, c111, fract_part.x);\n    \n    vec3 c0 = mix(c00, c10, fract_part.y);\n    vec3 c1 = mix(c01, c11, fract_part.y);\n    \n    return mix(c0, c1, fract_part.z);\n}\n\nvec4 fragment(vec4 color, vec2 coords, vec2 screen_size) {\n    // Assuming color is NOT premultiplied\n    \n    vec3 corrected = apply_lut(color.rgb);\n    return vec4(corrected, color.a);\n}\n")
    return "\n".join(glsl)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python cube_to_glsl.py <input.cube> <output.glsl>")
        sys.exit(1)
        
    infile = sys.argv[1]
    outfile = sys.argv[2]
    
    try:
        lut_size, data = parse_cube(infile)
        if lut_size == 0:
            print(f"Error: Could not parse LUT size from {infile}")
            sys.exit(1)
            
        glsl_code = generate_glsl(lut_size, data, infile)
        
        with open(outfile, 'w') as f:
            f.write(glsl_code)
        print(f"Converted {infile} to {outfile}")
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)