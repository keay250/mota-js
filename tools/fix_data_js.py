# -*- coding: utf-8 -*-
with open('_analysis/_ybfh-mota/project/data.js', 'r', encoding='utf-8') as f:
    text = f.read()

header = text.split('\n')[0]
body = text[len(header):]

out = []
in_str = False
escape = False

for ch in body:
    if ch == '"' and not escape:
        in_str = not in_str
        out.append(ch)
    elif in_str:
        if ch == '\n':
            out.append('\\n')
        elif ch == '\r':
            pass
        else:
            out.append(ch)
    else:
        out.append(ch)
    
    if ch == '\\' and not escape:
        escape = True
    else:
        escape = False

clean_content = header + ''.join(out)

with open('_analysis/_ybfh-mota/project/data.js', 'w', encoding='utf-8') as f:
    f.write(clean_content)

print("Successfully cleaned and escaped data.js!")
