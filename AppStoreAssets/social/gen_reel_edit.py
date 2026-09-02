#!/usr/bin/env python3
# Edited Reel: multiple scene cuts (each a settled app screen) with changing text
# callouts, crossfade transitions, an end card, and music. 1080x1920, IG safe zones.
# Source app footage must be springboard-free (we cut 12-46s of the raw take).
import os, subprocess, html, sys
W,H=1080,1920
CREAM="#FFF9F2"; PEACH="#FCEEDF"; AMBER="#F2BA69"; GOLD="#E08E33"; ESPRESSO="#281E15"; STONE="#6C5E51"; INK="#9C5615"
DEV_W=520; DEV_Y=505
RAW="/tmp/preview_cfr.mp4"   # CFR-normalized (simctl recording is VFR; span cuts fail on it)
MUSIC="/Users/can/Projects/MorningReset/AppStoreAssets/social/music/curtain_light_1.mp3"
REELDIR="/Users/can/Projects/MorningReset/AppStoreAssets/social/reels"
TMP="/tmp/reeledit"; os.makedirs(TMP,exist_ok=True)
XF=0.4; ENDDUR=2.4
# (start, duration, callout) — each clip stays INSIDE one screen's stable hold window
# (verified content @ CFR seconds: 13 Home, 18 Quiz, 28 PUSH, 34.5 Action, 42.5 Checkout)
VARIANTS={
 "1":{"out":f"{REELDIR}/reel1_ritual.mp4","music_start":14.0,"scenes":[
    (13.0, 2.8, ["Start calm,","not scrolling"]),
    (18.0, 2.6, ["A quick","check-in"]),
    (28.0, 2.6, ["Today's focus,","in one word"]),
    (34.5, 2.8, ["One small","movement"]),
    (42.5, 3.0, ["Seal it —","keep the streak"]),
 ]},
 "2":{"out":f"{REELDIR}/reel2_win.mp4","music_start":40.0,"scenes":[
    (13.0, 2.6, ["Wake up.","Reset."]),
    (28.0, 2.6, ["Find today's","focus"]),
    (34.5, 2.6, ["Do one","small thing"]),
    (42.5, 3.2, ["Seal it.","Keep the streak."]),
 ]},
}
VAR=sys.argv[1] if len(sys.argv)>1 else "1"
cfg=VARIANTS[VAR]; OUT=cfg["out"]; MUSIC_START=cfg["music_start"]; SCENES=cfg["scenes"]
def esc(s): return html.escape(s, quote=False)
def aura_defs():
    return f'''<defs>
 <radialGradient id="bg" cx="50%" cy="28%" r="85%"><stop offset="0%" stop-color="{PEACH}"/><stop offset="55%" stop-color="{CREAM}"/><stop offset="100%" stop-color="{CREAM}"/></radialGradient>
 <filter id="b"><feGaussianBlur stdDeviation="80"/></filter></defs>
 <rect width="{W}" height="{H}" fill="url(#bg)"/>
 <g filter="url(#b)" opacity="0.5"><circle cx="280" cy="520" r="340" fill="{AMBER}" opacity="0.5"/><circle cx="820" cy="1380" r="300" fill="{GOLD}" opacity="0.25"/><circle cx="600" cy="240" r="240" fill="{AMBER}" opacity="0.3"/></g>'''
def sun(cx,cy,r):
    import math
    rays="".join(f'<line x1="{cx+math.cos(math.radians(i*30))*r*1.35:.0f}" y1="{cy+math.sin(math.radians(i*30))*r*1.35:.0f}" x2="{cx+math.cos(math.radians(i*30))*r*1.7:.0f}" y2="{cy+math.sin(math.radians(i*30))*r*1.7:.0f}" stroke="{GOLD}" stroke-width="3" stroke-linecap="round" opacity="0.85"/>' for i in range(12))
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{GOLD}" stroke-width="3"/>{rays}'
def render(svg_body,path):
    open(path+".svg","w").write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">{svg_body}</svg>')
    subprocess.run(["rsvg-convert","-w",str(W),"-h",str(H),path+".svg","-o",path],check=True); os.remove(path+".svg")
def callout_bg(lines,path):
    t=f'<text x="{W/2}" y="300" text-anchor="middle" font-family="Georgia, serif" font-size="64" fill="{ESPRESSO}">'
    for i,ln in enumerate(lines): t+=f'<tspan x="{W/2}" dy="{0 if i==0 else 80}">{esc(ln)}</tspan>'
    t+='</text>'
    render(aura_defs()+t,path)
def endcard(path):
    body=aura_defs()
    body+=f'<g transform="translate({W/2},760)">'+sun(0,0,72)+'</g>'
    body+=f'<text x="{W/2}" y="960" text-anchor="middle" font-family="Georgia, serif" font-size="40" letter-spacing="6" fill="{INK}">MORNING RESET</text>'
    body+=f'<text x="{W/2}" y="1040" text-anchor="middle" font-family="Georgia, serif" font-size="44" fill="{ESPRESSO}">Your 3-minute morning ritual</text>'
    body+=f'<text x="{W/2}" y="1110" text-anchor="middle" font-family="Georgia, serif" font-size="30" fill="{STONE}">Free on the App Store</text>'
    render(body,path)

clips=[]
for i,(t,dur,lines) in enumerate(SCENES):
    bg=f"{TMP}/bg_{i}.png"; callout_bg(lines,bg)
    # accurate output-seek extraction (re-encoded): -ss AFTER -i is frame-accurate
    seg=f"{TMP}/raw_seg_{i}.mp4"
    subprocess.run(["ffmpeg","-y","-i",RAW,"-ss",str(t),"-t",str(dur),"-an",
        "-c:v","libx264","-pix_fmt","yuv420p","-r","30",seg],check=True,stderr=subprocess.DEVNULL)
    clip=f"{TMP}/scene_{i}.mp4"
    fc=(f"[1:v]scale={DEV_W}:-1,setpts=PTS-STARTPTS[d];"
        f"[0:v][d]overlay=(W-{DEV_W})/2:{DEV_Y},format=yuv420p,fps=30")
    subprocess.run(["ffmpeg","-y","-loop","1","-t",str(dur),"-i",bg,"-i",seg,
        "-filter_complex",fc,"-t",str(dur),"-r","30","-an","-c:v","libx264","-pix_fmt","yuv420p",clip],check=True,stderr=subprocess.DEVNULL)
    clips.append((clip,dur))
ec=f"{TMP}/endcard.png"; endcard(ec); ecclip=f"{TMP}/scene_end.mp4"
subprocess.run(["ffmpeg","-y","-loop","1","-t",str(ENDDUR),"-i",ec,"-r","30","-an","-c:v","libx264","-pix_fmt","yuv420p",ecclip],check=True,stderr=subprocess.DEVNULL)
clips.append((ecclip,ENDDUR))

# xfade chain
inputs=[];
for c,_ in clips: inputs+=["-i",c]
fc=[]; cur="0:v"; acc=clips[0][1]
for i in range(1,len(clips)):
    off=acc-XF; out=f"x{i}"
    fc.append(f"[{cur}][{i}:v]xfade=transition=fade:duration={XF}:offset={off:.3f}[{out}]")
    cur=out; acc=acc+clips[i][1]-XF
total=acc
fo=max(0.0,total-1.3)
fc.append(f"[{len(clips)}:a]atrim=start={MUSIC_START}:end={MUSIC_START+total:.3f},asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.7,afade=t=out:st={fo:.2f}:d=1.3,loudnorm=I=-16:TP=-1.5:LRA=11[a]")
cmd=["ffmpeg","-y"]+inputs+["-i",MUSIC,"-filter_complex",";".join(fc),"-map",f"[{cur}]","-map","[a]","-r","30","-c:v","libx264","-pix_fmt","yuv420p","-c:a","aac","-b:a","192k","-movflags","+faststart","-t",f"{total:.3f}",OUT]
subprocess.run(cmd,check=True,stderr=subprocess.DEVNULL)
print("OUT",OUT,"total %.2fs"%total)
