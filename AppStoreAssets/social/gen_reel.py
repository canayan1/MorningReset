#!/usr/bin/env python3
# Frame a simulator screen-recording into a 1080x1920 Instagram Reel, respecting
# IG safe zones (top ~250px and bottom ~420px + right action-button column are
# covered by IG UI -> keep all important content in the central band).
# Optional background music: trimmed to length, faded, loudness-normalized.
#
# Usage:
#   gen_reel.py "Hook 1|Hook 2" IN.mov SS TO SPEED OUT.mp4 [MUSIC.mp3] [MUSIC_START]
import sys, os, subprocess, html
W,H=1080,1920
CREAM="#FFF9F2"; PEACH="#FCEEDF"; AMBER="#F2BA69"; GOLD="#E08E33"; ESPRESSO="#281E15"; STONE="#6C5E51"; INK="#9C5615"
DEV_W=520           # device width (height auto from 1320x2868 source)
DEV_Y=505           # device top y  -> app buttons (~78% down) land ~y1386 (safe), bottom UI clear
HOOK_Y=300

a=sys.argv
hook, inv, ss, to, speed, out = a[1],a[2],a[3],a[4],a[5],a[6]
music = a[7] if len(a)>7 else None
music_start = float(a[8]) if len(a)>8 else 15.0
dur = (float(to)-float(ss))/float(speed)
lines=hook.split("|")
def esc(s): return html.escape(s, quote=False)

svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
svg.append(f'''<defs>
 <radialGradient id="bg" cx="50%" cy="28%" r="85%"><stop offset="0%" stop-color="{PEACH}"/><stop offset="55%" stop-color="{CREAM}"/><stop offset="100%" stop-color="{CREAM}"/></radialGradient>
 <filter id="b"><feGaussianBlur stdDeviation="80"/></filter></defs>
 <rect width="{W}" height="{H}" fill="url(#bg)"/>
 <g filter="url(#b)" opacity="0.5"><circle cx="280" cy="520" r="340" fill="{AMBER}" opacity="0.5"/><circle cx="820" cy="1380" r="300" fill="{GOLD}" opacity="0.25"/><circle cx="600" cy="240" r="240" fill="{AMBER}" opacity="0.3"/></g>''')
# hook (top safe band)
svg.append(f'<text x="{W/2}" y="{HOOK_Y}" text-anchor="middle" font-family="Georgia, serif" font-size="66" fill="{ESPRESSO}">')
for i,ln in enumerate(lines):
    svg.append(f'<tspan x="{W/2}" dy="{0 if i==0 else 82}">{esc(ln)}</tspan>')
svg.append('</text>')
# wordmark + CTA, also top-safe (above the device)
svg.append(f'<text x="{W/2}" y="452" text-anchor="middle" font-family="Georgia, serif" font-size="26" letter-spacing="4" fill="{INK}">MORNING RESET</text>')
svg.append(f'<text x="{W/2}" y="490" text-anchor="middle" font-family="Georgia, serif" font-size="22" fill="{STONE}">Free on the App Store</text>')
svg.append('</svg>')
bgp=out.replace(".mp4","_bg.png")
open(bgp+".svg","w").write("\n".join(svg))
subprocess.run(["rsvg-convert","-w",str(W),"-h",str(H),bgp+".svg","-o",bgp],check=True)
os.remove(bgp+".svg")

vid_fc=f"[1:v]setpts=(PTS-STARTPTS)/{speed},scale={DEV_W}:-1[scr];[0:v][scr]overlay=(W-{DEV_W})/2:{DEV_Y}:shortest=1,format=yuv420p[v]"
cmd=["ffmpeg","-y","-loop","1","-i",bgp,"-ss",ss,"-to",to,"-i",inv]
if music:
    cmd+=["-i",music]
    fo=max(0.0,dur-1.3)
    aud_fc=f"[2:a]atrim=start={music_start}:end={music_start+dur},asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.7,afade=t=out:st={fo:.2f}:d=1.3,loudnorm=I=-16:TP=-1.5:LRA=11[a]"
    cmd+=["-filter_complex",vid_fc+";"+aud_fc,"-map","[v]","-map","[a]","-c:a","aac","-b:a","192k","-shortest"]
else:
    cmd+=["-filter_complex",vid_fc,"-map","[v]"]
cmd+=["-r","30","-c:v","libx264","-pix_fmt","yuv420p","-movflags","+faststart",out]
subprocess.run(cmd,check=True,stderr=subprocess.DEVNULL)
info=subprocess.run(["ffprobe","-v","error","-show_entries","stream=codec_type,width,height","-show_entries","format=duration","-of","default=noprint_wrappers=1",out],capture_output=True,text=True).stdout
print("OUT",out,"\n",info)
