SIGNAL_HORZ = 'hatchH'
SIGNAL_VERT = 'hatchV'
GRID_HORZ = 'gridH'
GRID_VERT = 'gridV'
MARK_VOLT = 'voltMarker'
MARK_TIME = 'timeMarker'
HATCH_WIDTH = 3
WINDOW_WIDTH = 1000
WINDOW_HEIGHT = 500
WINDOW_LEFT = 140
WINDOW_TOP = 110
MARKER_HALF_BASE = 7

grid_interval_h = WINDOW_HEIGHT / 10
grid_interval_v = WINDOW_WIDTH / 10
hatch_interval_h = WINDOW_WIDTH / 50
hatch_interval_v = WINDOW_HEIGHT / 50
midpoint_h = WINDOW_WIDTH / 2
midpoint_v = WINDOW_HEIGHT / 2

# Vertical (Voltage) Trigger Marker
print(f"""{MARK_VOLT} <= '1' when """, end='')
for i in range(MARKER_HALF_BASE + 1):
    if i > 0:
        print('or ', end='')
    print(f"pixelH = L_EDGE + BORDER_LINE_WIDTH + {i+1} and pixelV <= triggerVolt + {MARKER_HALF_BASE-i} and pixelV >= triggerVolt - {MARKER_HALF_BASE-i}")
print()
"""
{MARK_VOLT} <= '1' when pixelH = L_EDGE + BORDER_LINE_WIDTH + 1 and pixelV <= triggerVolt + {MARKER_HALF_BASE} and pixelV >= triggerVolt - {MARKER_HALF_BASE}
or pixelH = L_EDGE + BORDER_LINE_WIDTH + 2 and pixelV <= triggerVolt + {MARKER_HALF_BASE} - 1 and pixelV >= triggerVolt - {MARKER_HALF_BASE} + 1
or ...
else '0';
"""

# Horizontal Grid Lines
print(f"""{GRID_HORZ} <= '1' when pixelH >= L_EDGE and pixelH <= R_EDGE and (""")
print(f'    pixelV = {WINDOW_TOP}')
v_pos = int(WINDOW_TOP + grid_interval_h)
while v_pos < WINDOW_TOP + WINDOW_HEIGHT:
    print(f'    or pixelV = {v_pos}')
    v_pos = int(v_pos + grid_interval_h)
print(f") else '0';")
print()

# Vertical Grid Lines
print(f"""{GRID_VERT} <= '1' when pixelV >= T_EDGE and pixelV <= B_EDGE and (""")
print(f'    pixelH = {WINDOW_LEFT}')
h_pos = int(WINDOW_LEFT + grid_interval_v)
while h_pos < WINDOW_LEFT + WINDOW_WIDTH:
    print(f'    or pixelH = {h_pos}')
    h_pos = int(h_pos + grid_interval_v)
print(f") else '0';")
print()

# Hatch marks on horizontal line
print(f"""{SIGNAL_HORZ} <= '1' when (pixelV <= {int(midpoint_v + HATCH_WIDTH)}) and (pixelV >= {int(midpoint_v - HATCH_WIDTH)}) and
    (""")
print(f'        pixelH = {WINDOW_LEFT}')
h_pos = int(WINDOW_LEFT + hatch_interval_h)
while h_pos < WINDOW_LEFT + WINDOW_WIDTH:
    print(f'        or pixelH = {h_pos}')

    h_pos = int(h_pos + hatch_interval_h)
print(f"""    )
    else '0';""")
print()

# Hatch marks on verticle line
print(f"""{SIGNAL_VERT} <= '1' when (pixelH <= {int(midpoint_h + HATCH_WIDTH)}) and (pixelH >= {int(midpoint_h - HATCH_WIDTH)}) and
    (""")
print(f'        pixelV = {WINDOW_TOP}')
v_pos = int(WINDOW_TOP + hatch_interval_v)
while v_pos < WINDOW_TOP + WINDOW_HEIGHT:
    print(f'        or pixelV = {v_pos}')

    v_pos = int(v_pos + hatch_interval_v)
print(f"""    )
    else '0';""")

"""
hatchH <= '1' when (pixelV <= midpoint_v + HATCH_WIDTH) and (pixelV >= midpoint_v - HATCH_WIDTH) and
    (
        pixelH = WINDOW_LEFT
        or pixelH = WINDOW_LEFT + hatch
    )
    else '0';
"""