#!/usr/bin/env python3
# Branded Instagram carousel generator for Morning Reset.
# Renders 1080x1350 slides as PNG via rsvg-convert. Reusable: edit CAROUSELS and re-run.
import os, subprocess, html
W,H=1080,1350
OUT=os.path.dirname(os.path.abspath(__file__))+"/carousels"
# palette (DS mimoza)
CREAM="#FFF9F2"; PEACH="#FCEEDF"; AMBER="#F2BA69"; GOLD="#E08E33"
ESPRESSO="#281E15"; STONE="#6C5E51"; INK="#9C5615"
def esc(s): return html.escape(s, quote=False)
def aura():
    return f'''
  <defs>
    <radialGradient id="bg" cx="50%" cy="38%" r="80%">
      <stop offset="0%" stop-color="{PEACH}"/>
      <stop offset="60%" stop-color="{CREAM}"/>
      <stop offset="100%" stop-color="{CREAM}"/>
    </radialGradient>
    <filter id="blur"><feGaussianBlur stdDeviation="70"/></filter>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#bg)"/>
  <g filter="url(#blur)" opacity="0.55">
    <circle cx="300" cy="430" r="300" fill="{AMBER}" opacity="0.5"/>
    <circle cx="820" cy="760" r="280" fill="{GOLD}" opacity="0.30"/>
    <circle cx="560" cy="240" r="220" fill="{AMBER}" opacity="0.35"/>
  </g>'''
def sun(cx,cy,r,col):
    rays=""
    import math
    for i in range(12):
        a=math.radians(i*30)
        x1=cx+math.cos(a)*(r*1.35); y1=cy+math.sin(a)*(r*1.35)
        x2=cx+math.cos(a)*(r*1.7); y2=cy+math.sin(a)*(r*1.7)
        rays+=f'<line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" stroke="{col}" stroke-width="3" stroke-linecap="round" opacity="0.8"/>'
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{col}" stroke-width="3"/>{rays}'
def dots(idx,total):
    g="";cx0=W/2-(total-1)*16/2
    for i in range(total):
        op="1" if i==idx else "0.28"
        g+=f'<circle cx="{cx0+i*16:.0f}" cy="1290" r="5" fill="{GOLD}" opacity="{op}"/>'
    return g
def wordmark():
    return f'''<g transform="translate({W/2},1230)">
      <text x="0" y="0" text-anchor="middle" font-family="Georgia, serif" font-size="26" letter-spacing="4" fill="{INK}">MORNING RESET</text>
    </g>'''
def text_block(lines,y,size,fill,family="Georgia, serif",weight="normal",lh=1.18,ls="0"):
    out=f'<text x="{W/2}" y="{y}" text-anchor="middle" font-family="{family}" font-size="{size}" font-weight="{weight}" fill="{fill}" letter-spacing="{ls}">'
    for i,ln in enumerate(lines):
        dy=0 if i==0 else size*lh
        out+=f'<tspan x="{W/2}" dy="{dy:.0f}">{esc(ln)}</tspan>'
    return out+'</text>'
def slide(kind,head,body,idx,total,tag=None):
    svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',aura()]
    if kind=="cover":
        svg.append(f'<g transform="translate({W/2},300)">'+sun(0,0,70,GOLD)+'</g>')
        svg.append(text_block(head,560,82,ESPRESSO,weight="normal",lh=1.12))
        by=560+len(head)*82*1.12+70
        svg.append(text_block(body,by,38,STONE,family="Georgia, serif"))
    elif kind=="cta":
        svg.append(f'<g transform="translate({W/2},340)">'+sun(0,0,60,GOLD)+'</g>')
        svg.append(text_block(head,580,72,ESPRESSO,lh=1.14))
        by=580+len(head)*72*1.14+80
        svg.append(f'<rect x="{W/2-260}" y="{by-58}" width="520" height="92" rx="46" fill="{GOLD}"/>')
        svg.append(text_block(body[:1],by+6,34,CREAM))
        if len(body)>1: svg.append(text_block(body[1:],by+120,30,STONE))
    else:
        if tag: svg.append(text_block([tag],420,30,GOLD,ls="6"))
        svg.append(text_block(head,540,72,ESPRESSO,lh=1.12))
        by=540+len(head)*72*1.12+60
        svg.append(f'<line x1="{W/2-44}" y1="{by-42}" x2="{W/2+44}" y2="{by-42}" stroke="{GOLD}" stroke-width="3"/>')
        svg.append(text_block(body,by,40,STONE,lh=1.3))
    svg.append(dots(idx,total)); svg.append(wordmark()); svg.append('</svg>')
    return "\n".join(svg)

CAROUSELS={
 "c1_energy":[
   ("cover",["Wake your energy","— no caffeine"],["5 gentle ways to rise"],None),
   ("body",["Let the light in"],["Open the curtains in","your first waking minute."],"01"),
   ("body",["Move for","sixty seconds"],["A short stretch wakes the","body before the mind."],"02"),
   ("body",["Breathe slow"],["A few long breaths","to feel awake and settled."],"03"),
   ("body",["Water before","coffee"],["A glass first — rehydrate","the night away."],"04"),
   ("body",["One small win"],["Finish a tiny first task.","Momentum beats motivation."],"05"),
   ("cta",["Your 3-minute","morning ritual"],["Get Morning Reset","Free on the App Store"],None),
 ],
 "c2_sound":[
   ("cover",["3 sound & breath","rituals to try"],["from contemplative traditions"],None),
   ("body",["Bhramari","humming breath"],["Exhale with a soft hum —","a calming yogic practice."],"01"),
   ("body",["Six Healing","Sounds"],["Qigong's gentle vocal","exhales, one per breath."],"02"),
   ("body",["Let a bell ring"],["Strike one tone and","follow it as it fades."],"03"),
   ("body",["Just for calm"],["Experiential practices —","not medicine."],"04"),
   ("cta",["Wind down with","Morning Reset"],["Nighttime soundscapes","Free on the App Store"],None),
 ],
 "c3_habit":[
   ("cover",["One tiny win","beats a big plan"],["the morning-momentum effect"],None),
   ("body",["Big plans stall"],["A long to-do list at 7am","is easy to snooze."],"01"),
   ("body",["Small wins start"],["One finished task builds","momentum for the next."],"02"),
   ("body",["Streaks stick"],["Doing it daily matters","more than doing it big."],"03"),
   ("body",["Commit the","night before"],["Pick tomorrow's one win","tonight."],"04"),
   ("cta",["Build your streak"],["Get Morning Reset","Free on the App Store"],None),
 ],
 "c4_sunlight":[
   ("cover",["Catch the light","in your first hour"],["a simple morning anchor"],None),
   ("body",["Step outside"],["A minute of morning light,","even through clouds."],"01"),
   ("body",["Coffee by","a window"],["Pair your first cup","with daylight."],"02"),
   ("body",["Sky before","screen"],["Let your eyes wake","on the horizon first."],"03"),
   ("body",["Make it a cue"],["Light is the signal your","morning has started."],"04"),
   ("cta",["Begin with","intention"],["Get Morning Reset","Free on the App Store"],None),
 ],
 "c5_evening":[
   ("cover",["A 5-minute","evening wind-down"],["set tomorrow up tonight"],None),
   ("body",["Dim the lights"],["Lower the brightness an","hour before bed."],"01"),
   ("body",["One slow sound"],["A soft tone or hum to","let the day settle."],"02"),
   ("body",["Name tomorrow's","one win"],["Decide it tonight, so","morning is easy."],"03"),
   ("body",["Screens down"],["Let the last minutes","be quiet."],"04"),
   ("cta",["Wind down with","Morning Reset"],["Nighttime soundscapes","Free on the App Store"],None),
 ],
}
import sys
only=sys.argv[1] if len(sys.argv)>1 else None
for name,slides in CAROUSELS.items():
    if only and name!=only: continue
    d=f"{OUT}/{name}"; os.makedirs(d,exist_ok=True)
    total=len(slides)
    for i,(kind,head,body,tag) in enumerate(slides):
        svg=slide(kind,head,body,i,total,tag)
        sp=f"{d}/slide_{i+1:02d}.svg"; pp=f"{d}/slide_{i+1:02d}.png"
        open(sp,"w").write(svg)
        subprocess.run(["rsvg-convert","-w",str(W),"-h",str(H),sp,"-o",pp],check=True)
        os.remove(sp)
    print(f"{name}: {total} slides -> {d}")
