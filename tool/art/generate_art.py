# Generates the run4share template and onboarding illustrations (landscapes, no people) as SVG.
# Run: python3 tool/art/generate_art.py, then rsvg-convert -w 1080 -h 1920 X.svg -o X.png and save as JPG (quality 88). See docs/illustrations.md.
import math, random
W,H=360,640
def svg(body,bg): return f'<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1920" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="{bg}"/>{body}</svg>'
def bands(cols,y0,y1):
    n=len(cols);h=(y1-y0)/n
    return ''.join(f'<rect x="0" y="{y0+i*h:.1f}" width="{W}" height="{h+1:.1f}" fill="{c}"/>' for i,c in enumerate(cols))
def sun(x,y,r,c,halo=None):
    s=''
    if halo: s+=f'<circle cx="{x}" cy="{y}" r="{r*1.6}" fill="{halo}" opacity="0.35"/><circle cx="{x}" cy="{y}" r="{r*1.25}" fill="{halo}" opacity="0.4"/>'
    return s+f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}"/>'
def cloud(x,y,s,c,o=0.9):
    return f'<g fill="{c}" opacity="{o}"><ellipse cx="{x}" cy="{y}" rx="{28*s}" ry="{9*s}"/><ellipse cx="{x-12*s}" cy="{y-6*s}" rx="{13*s}" ry="{10*s}"/><ellipse cx="{x+8*s}" cy="{y-9*s}" rx="{15*s}" ry="{12*s}"/></g>'
def ridge(pts,c,base=H):
    d='M0 %s '%base+' '.join(f'L{x} {y}' for x,y in pts)+f' L{W} {base} Z'
    return f'<path d="{d}" fill="{c}"/>'
def hill(y,amp,c,phase=0,base=H,n=4):
    d=f'M0 {base} L0 {y}'
    for i in range(n):
        x0=W*i/n;x1=W*(i+1)/n;cy=y+(amp if (i+phase)%2 else -amp)
        d+=f' Q{(x0+x1)/2} {cy} {x1} {y}'
    return f'<path d="{d} L{W} {base} Z" fill="{c}"/>'
def pine(x,y,h,c): return f'<path d="M{x} {y-h} L{x+h*0.32} {y-h*0.35} L{x+h*0.18} {y-h*0.35} L{x+h*0.4} {y} L{x-h*0.4} {y} L{x-h*0.18} {y-h*0.35} L{x-h*0.32} {y-h*0.35} Z" fill="{c}"/>'
def tree(x,y,r,c,trunk): return f'<rect x="{x-1.5}" y="{y-r*0.4}" width="3" height="{r*1.2}" fill="{trunk}"/><circle cx="{x}" cy="{y-r}" r="{r}" fill="{c}"/>'
def snow(px,py,w,c='#F7F1E8'): return f'<path d="M{px} {py} L{px+w} {py+w*1.1} L{px+w*0.45} {py+w*0.8} L{px} {py+w*1.2} L{px-w*0.5} {py+w*0.85} L{px-w} {py+w*1.1} Z" fill="{c}"/>'
def limb(pts,c,w): return f'<polyline points="{" ".join(f"{a:.1f},{b:.1f}" for a,b in pts)}" fill="none" stroke="{c}" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"/>'
def runner(x,y,s,c,flip=False,phase=0):
    # y = foot line; scale s ~ height/100
    f=-1 if flip else 1
    P=lambda a,b:(x+f*a*s,y+b*s)
    sw=9*s
    g=[]
    legs=[[P(-4,-52),P(8,-28),P(-2,-2)],[P(-4,-52),P(-18,-30),P(-34,-34)]] if phase==0 else [[P(-4,-52),P(4,-26),P(14,-4)],[P(-4,-52),P(-14,-28),P(-26,-12)]]
    arms=[[P(2,-86),P(16,-70),P(26,-80)],[P(2,-86),P(-14,-74),P(-20,-58)]]
    g.append(limb(legs[1],c,sw)); g.append(limb(arms[1],c,sw*0.8))
    g.append(limb([P(-4,-52),P(2,-88)],c,sw*1.5))
    g.append(limb(legs[0],c,sw)); g.append(limb(arms[0],c,sw*0.8))
    hx,hy=P(5,-100); g.append(f'<circle cx="{hx:.1f}" cy="{hy:.1f}" r="{8.5*s:.1f}" fill="{c}"/>')
    return ''.join(g)
def walker(x,y,s,c):
    P=lambda a,b:(x+a*s,y+b*s);sw=9*s
    return limb([P(0,-52),P(-8,-26),P(-12,0)],c,sw)+limb([P(0,-90),P(-10,-70),P(-12,-52)],c,sw*0.8)+limb([P(0,-52),P(2,-90)],c,sw*1.5)+limb([P(0,-52),P(10,-26),P(14,0)],c,sw)+limb([P(2,-88),P(12,-68),P(14,-52)],c,sw*0.8)+f'<circle cx="{x+3*s:.1f}" cy="{y-102*s:.1f}" r="{8.5*s:.1f}" fill="{c}"/>'
def hiker(x,y,s,c,pole='#2A2A28'):
    P=lambda a,b:(x+a*s,y+b*s);sw=9*s
    bx,by=P(-16,-92)
    return (limb([P(-2,-50),P(-10,-26),P(-18,0)],c,sw)+f'<rect x="{bx:.1f}" y="{by:.1f}" width="{16*s:.1f}" height="{34*s:.1f}" rx="{4*s:.1f}" fill="{c}"/>'
            +limb([P(-2,-50),P(2,-90)],c,sw*1.5)+limb([P(-2,-50),P(10,-28),P(12,0)],c,sw)+limb([P(2,-86),P(16,-66),P(22,-60)],c,sw*0.8)
            +limb([P(22,-60),P(30,0)],pole,3*s)+f'<circle cx="{x+5*s:.1f}" cy="{y-102*s:.1f}" r="{8.5*s:.1f}" fill="{c}"/>')
def cyclist(x,y,s,c,frame=None):
    frame=frame or c
    P=lambda a,b:(x+a*s,y+b*s);r=22*s
    w1=P(-36,-22);w2=P(36,-22)
    g=f'<circle cx="{w1[0]:.1f}" cy="{w1[1]:.1f}" r="{r:.1f}" fill="none" stroke="{c}" stroke-width="{5*s:.1f}"/><circle cx="{w2[0]:.1f}" cy="{w2[1]:.1f}" r="{r:.1f}" fill="none" stroke="{c}" stroke-width="{5*s:.1f}"/>'
    g+=limb([w1,P(-8,-52),P(22,-52),w2],frame,5*s)+limb([P(-8,-52),P(2,-22),P(22,-52)],frame,5*s)+limb([P(22,-52),P(18,-64),P(28,-66)],frame,4*s)+limb([P(-10,-56),P(-4,-60)],frame,5*s)
    g+=limb([P(-6,-60),P(4,-90)],c,13*s)+limb([P(-6,-60),P(10,-40),P(2,-22)],c,9*s)+limb([P(2,-88),P(16,-74),P(26,-66)],c,7*s)
    g+=f'<circle cx="{x+12*s:.1f}" cy="{y-100*s:.1f}" r="{8.5*s:.1f}" fill="{c}"/>'
    return g
def road(xc,ytop,wtop,wbot,c,line=None):
    s=f'<path d="M{xc-wtop/2} {ytop} L{xc+wtop/2} {ytop} L{xc+wbot/2} {H} L{xc-wbot/2} {H} Z" fill="{c}"/>'
    if line:
        for i in range(6):
            t0=i/6+0.04;t1=t0+0.07
            y0=ytop+(H-ytop)*t0**1.6;y1=ytop+(H-ytop)*t1**1.6
            s+=f'<path d="M{xc} {y0:.1f} L{xc} {y1:.1f}" stroke="{line}" stroke-width="{1+5*t1:.1f}"/>'
    return s
def lights(x0,y0,w,h,c,rnd,step=9):
    s=''
    for xx in range(int(x0)+4,int(x0+w)-4,step):
        for yy in range(int(y0)+6,int(y0+h)-4,12):
            if rnd.random()<0.55: s+=f'<rect x="{xx}" y="{yy}" width="4" height="5" fill="{c}"/>'
    return s
runner=lambda *a,**k:'';walker=lambda *a,**k:'';hiker=lambda *a,**k:'';cyclist=lambda *a,**k:''
R=random.Random(7)
S={}
# 1 sunrise-half
S['templates/sunrise-half']=svg(bands(['#F7C58A','#F4B272','#F2A160'],0,330)+sun(250,250,46,'#FCE6B8','#FAD49A')+cloud(80,120,1.2,'#FBD9AE')+cloud(270,80,0.9,'#FBD9AE')
 +ridge([(0,320),(60,285),(110,300),(170,262),(230,290),(300,255),(360,280)],'#D9895A')+hill(345,14,'#B5643C',0)+hill(395,10,'#8E4A30',1)
 +road(180,350,10,250,'#4A2C24','#E9B07A')+runner(196,500,1.45,'#1E1411')+hill(560,6,'#6E3B2A',0,H,3),'#F2A160')
# 2 summit-day
S['templates/summit-day']=svg(bands(['#D6E6EE','#C9DDE6'],0,320)+cloud(90,90,1.3,'#FFFFFF',0.8)+cloud(290,140,0.9,'#FFFFFF',0.7)
 +ridge([(0,300),(70,210),(120,250),(200,150),(270,240),(320,200),(360,230)],'#9AB3B0')+snow(200,150,22)+snow(70,210,14)+snow(320,200,12)
 +ridge([(0,350),(90,280),(170,330),(250,270),(360,320)],'#6E8D7C')+''.join(pine(x,y,h,'#3E5A47') for x,y,h in [(20,380,70),(48,372,90),(300,370,85),(330,380,70),(350,368,95)])
 +hill(400,10,'#4E6B55',1)+f'<path d="M110 {H} C150 560 190 520 236 420" stroke="#D2BE92" stroke-width="26" fill="none" stroke-linecap="round"/>'+hiker(226,470,1.35,'#1A1A14')+hill(560,5,'#3A5240',0),'#C9DDE6')
# 3 mountain-climb
S['templates/mountain-climb']=svg(bands(['#A8D2F0','#8CC4EC'],0,330)+cloud(270,90,1.1,'#FFFFFF',0.85)+cloud(70,150,0.8,'#FFFFFF',0.7)
 +ridge([(0,300),(80,180),(140,250),(220,130),(300,230),(360,190)],'#6F8EA0')+snow(220,130,24)+snow(80,180,16)
 +ridge([(0,360),(120,300),(250,340),(360,300)],'#4F8A72')+hill(420,12,'#3F7A6A',0)
 +'<path d="M-10 620 C110 590 80 520 190 500 S320 450 370 440" stroke="#2C2C2A" stroke-width="30" fill="none"/><path d="M-10 620 C110 590 80 520 190 500 S320 450 370 440" stroke="#F7F1E8" stroke-width="1.5" stroke-dasharray="8 8" fill="none"/>'
 +cyclist(178,498,1.25,'#14181C','#C0533A'),'#8CC4EC')
# 4 final-score night run
cs='';xs=0
for w,h in [(52,250),(44,190),(62,280),(40,210),(56,300),(48,230),(58,260)]:
    cs+=f'<rect x="{xs}" y="{470-h}" width="{w}" height="{h}" fill="#2E3460"/>'+lights(xs,470-h,w,h-10,'#F5C76B',R);xs+=w+2
S['templates/final-score']=svg(bands(['#151935','#1B2042','#22284D'],0,470)+sun(290,90,22,'#F1E9D2')+''.join(f'<circle cx="{R.randint(5,355)}" cy="{R.randint(10,200)}" r="0.9" fill="#F1E9D2"/>' for _ in range(40))
 +cs+'<rect y="470" width="360" height="170" fill="#11132A"/><rect y="470" width="360" height="8" fill="#3B4C7A"/>'
 +''.join(f'<rect x="{x}" y="{485+i*14}" width="{18-i*2}" height="2" fill="#F5C76B" opacity="0.5"/>' for i,x in enumerate([60,120,200,270]))
 +''.join(f'<rect x="{x}" y="430" width="3" height="40" fill="#5A6496"/><circle cx="{x+1.5}" cy="428" r="5" fill="#F5C76B"/>' for x in [40,160,280])
 +runner(150,560,1.35,'#F7F1E8',phase=1),'#151935')
# 5 race-day track
lanes=''.join(f'<path d="M{150+i*12} 330 L{-260+i*110} {H}" stroke="#F7F1E8" stroke-width="2.5"/>' for i in range(9))
S['templates/race-day']=svg(bands(['#8EC7EA','#6FB6E2'],0,250)+cloud(80,80,1.0,'#FFFFFF',0.85)
 +'<rect y="230" width="360" height="70" fill="#4A4F66"/>'+''.join(f'<rect x="{x}" y="{238+r*10}" width="6" height="6" rx="3" fill="{R.choice(["#F59A1F","#E5E0D8","#0077BD","#C0533A","#F7F1E8"])}"/>' for x in range(4,360,9) for r in range(5))
 +'<rect y="300" width="360" height="30" fill="#2E7D4F"/><path d="M0 330 L360 330 L360 640 L0 640Z" fill="#C0533A"/>'+lanes
 +'<rect x="40" y="250" width="4" height="80" fill="#E5E0D8"/><rect x="316" y="250" width="4" height="80" fill="#E5E0D8"/><rect x="40" y="250" width="280" height="16" fill="#0077BD"/>'
 +runner(220,520,1.6,'#16100E'),'#6FB6E2')
# 6 run-receipt golden park
S['templates/run-receipt']=svg(bands(['#F6D9A0','#F3C983','#EFB86C'],0,340)+sun(80,260,40,'#FFF0C8','#FBE3A6')
 +hill(330,16,'#C9A35E',0)+''.join(tree(x,y,r,'#8C7A3E','#5C4A2A') for x,y,r in [(30,350,30),(90,340,24),(290,345,32),(345,352,22),(200,335,18)])
 +hill(380,8,'#A08848',1)+f'<path d="M60 {H} C120 540 200 460 250 380" stroke="#E8D3A2" stroke-width="40" fill="none"/>'
 +''.join(f'<rect x="{x}" y="{y}" width="3" height="{h}" fill="#4A4A35"/><circle cx="{x+1.5}" cy="{y}" r="4" fill="#FFF0C8"/>' for x,y,h in [(300,400,60),(40,430,70)])
 +runner(186,500,1.45,'#2A2418')+hill(580,5,'#7E6A36',0),'#EFB86C')
# 7 coast-walk
S['templates/coast-walk']=svg(bands(['#D3E6F0','#BFD9E8'],0,250)+cloud(240,90,1.1,'#FFFFFF',0.8)+sun(90,110,22,'#FFF6DE')
 +'<rect y="250" width="360" height="170" fill="#2E92CE"/>'+''.join(f'<path d="M{x} {y} q8 -4 16 0" stroke="#BFE0F4" stroke-width="2" fill="none"/>' for x,y in [(150,290),(220,320),(170,360),(260,380),(200,400)])
 +'<path d="M0 230 L60 205 L110 240 L130 640 L0 640Z" fill="#7A6A55"/><path d="M0 300 L90 290 L120 640 L0 640Z" fill="#5C4E3D"/>'
 +'<path d="M360 360 L300 300 L270 420 L360 430Z" fill="#6B5A46"/><path d="M120 640 L120 430 C200 410 280 440 360 420 L360 640Z" fill="#D8C49A"/>'
 +'<path d="M120 455 C200 440 280 462 360 448" stroke="#F7F1E8" stroke-width="3" fill="none" opacity="0.8"/>'+walker(228,560,1.4,'#1C1A16'),'#BFD9E8')
# 8 story-hero forest trail
S['templates/story-hero']=svg(bands(['#E4EDE0','#D6E5D2'],0,330)
 +''.join(pine(x,330,h,'#A9C3A6') for x,h in [(10,140),(60,170),(110,150),(250,160),(300,180),(350,150)])
 +''.join(pine(x,400,h,'#6F9670') for x,h in [(0,200),(50,180),(300,210),(345,190)])
 +hill(400,8,'#557A57',0)+f'<path d="M120 {H} C150 560 190 480 190 400" stroke="#C9AE80" stroke-width="44" fill="none"/>'
 +''.join(pine(x,H,h,'#2F4A33') for x,h in [(10,260),(352,280)])+runner(176,500,1.45,'#1C2418'),'#D6E5D2')
# 9 top-line countryside ride
S['templates/top-line']=svg(bands(['#BEE0F4','#A9D4EE'],0,320)+cloud(100,100,1.2,'#FFFFFF',0.9)+cloud(280,150,0.8,'#FFFFFF',0.8)
 +hill(320,12,'#9CC27A',0)+hill(360,10,'#E2C25A',1)+hill(400,10,'#7FAE5E',0)
 +''.join(tree(x,y,r,'#4F7D3E','#5C4A2A') for x,y,r in [(40,330,12),(70,328,9),(300,322,14),(330,330,10)])
 +road(180,410,20,330,'#3C3A37','#F7F1E8')+cyclist(182,520,1.35,'#14181C','#0077BD'),'#A9D4EE')
# 10 left-stack bridge city day
S['templates/left-stack']=svg(bands(['#CFE3EF','#BCD8EA'],0,300)+cloud(260,90,1.0,'#FFFFFF',0.85)
 +''.join(f'<rect x="{x}" y="{300-h}" width="{w}" height="{h}" fill="{c}"/>' for x,w,h,c in [(0,40,120,'#9FB2C2'),(42,30,160,'#8EA3B5'),(76,50,100,'#A9BBCA'),(250,36,140,'#8EA3B5'),(290,44,180,'#9FB2C2'),(336,30,110,'#A9BBCA')])
 +'<rect y="300" width="360" height="120" fill="#5F9CC2"/>'+''.join(f'<path d="M{x} {y} q10 -4 20 0" stroke="#A9CFE6" stroke-width="2" fill="none"/>' for x,y in [(40,330),(260,350),(120,380),(300,400)])
 +'<path d="M0 420 L360 400 L360 412 L0 432Z" fill="#6B6762"/>'+''.join(f'<rect x="{x}" y="{380+x*-0.055:.0f}" width="3" height="30" fill="#4A4642"/>' for x in range(10,360,40))
 +'<path d="M0 432 L360 412 L360 640 L0 640Z" fill="#B9B2A8"/>'+runner(176,540,1.5,'#1A1A20'),'#BCD8EA')
# 11 race-poster evening race
crowd=''.join(runner(x,y,s,c,phase=p) for x,y,s,c,p in [(90,505,0.95,'#3A2440',1),(270,500,0.9,'#3A2440',0),(140,525,1.15,'#24162A',0),(220,520,1.1,'#24162A',1)])
S['templates/race-poster']=svg(bands(['#4A3A6E','#6B4E7A','#9A6178','#C07A5A'],0,380)+sun(180,330,40,'#F6C28A','#E9A37A')
 +''.join(f'<rect x="{x}" y="{380-h}" width="{w}" height="{h}" fill="#2A2235"/>' for x,w,h in [(0,50,140),(52,30,100),(84,44,170),(250,40,150),(292,30,110),(324,36,160)])
 +'<rect y="380" width="360" height="260" fill="#3A3048"/>'+road(180,380,120,520,'#2A2235')
 +'<rect x="70" y="250" width="8" height="140" fill="#F59A1F"/><rect x="282" y="250" width="8" height="140" fill="#F59A1F"/><rect x="70" y="250" width="220" height="22" rx="3" fill="#F59A1F"/>'
 +crowd+runner(184,575,1.45,'#140D18'),'#4A3A6E')
# onboarding p1 blue-hour lakeside
S['onboarding/page1']=svg(bands(['#5E7FA8','#7B98BD','#A3B6CF','#D9B8A4'],0,330)+sun(260,320,26,'#F6D2AE')
 +ridge([(0,320),(80,270),(150,300),(230,250),(300,290),(360,270)],'#4B5F80')+'<rect y="320" width="360" height="90" fill="#6E89AE"/>'
 +'<path d="M230 330 L290 330" stroke="#F6D2AE" stroke-width="2" opacity="0.7"/><path d="M240 345 L280 345" stroke="#F6D2AE" stroke-width="2" opacity="0.5"/>'
 +'<path d="M0 410 L360 395 L360 640 L0 640Z" fill="#3A465E"/>'+''.join(pine(x,410,h,'#2A3448') for x,h in [(14,90),(40,70),(330,100)])
 +runner(190,520,1.5,'#141820'),'#5E7FA8')
# p2 forest group
S['onboarding/page2']=svg(bands(['#CFDCC4','#BFD0B2'],0,300)+''.join(pine(x,330,h,'#93AE8A') for x,h in [(20,160),(70,190),(130,150),(240,170),(300,200),(350,160)])
 +''.join(tree(x,y,r,'#4F7350','#3C2E22') for x,y,r in [(30,380,40),(330,385,44)])+hill(380,6,'#6B8F62',0)
 +'<path d="M0 470 C120 440 240 480 360 450 L360 640 L0 640Z" fill="#B8A27A"/>'
 +runner(110,520,1.2,'#1E2418',phase=1)+runner(190,515,1.25,'#1E2418')+runner(270,522,1.2,'#1E2418',phase=1),'#BFD0B2')
# p3 urban street dusk
S['onboarding/page3']=svg(bands(['#E8B38A','#D99A7A','#B9807A'],0,300)
 +''.join(f'<rect x="{x}" y="{y}" width="{w}" height="{640-y}" fill="{c}"/>' for x,y,w,c in [(0,90,70,'#6B4E5A'),(290,70,70,'#6B4E5A'),(70,180,40,'#7E5E66'),(250,170,40,'#7E5E66')])
 +''.join(lights(x,y+10,w,200,'#F6D2AE',R,11) for x,y,w in [(0,90,70),(290,70,70)])
 +road(180,300,40,420,'#4A3A40','#F6D2AE')+'<path d="M110 640 L160 300 L140 300 L0 600Z" fill="#8E6E72"/><path d="M250 640 L200 300 L220 300 L360 600Z" fill="#8E6E72"/>'
 +runner(186,520,1.5,'#1A1216'),'#D99A7A')
# p4 night mountain headlamp
S['onboarding/page4']=svg(bands(['#0F1420','#151B2A','#1C2335'],0,360)+''.join(f'<circle cx="{R.randint(5,355)}" cy="{R.randint(10,260)}" r="{R.choice([0.7,0.9,1.2])}" fill="#E5E0D8"/>' for _ in range(70))
 +ridge([(0,330),(90,230),(160,290),(240,200),(320,280),(360,250)],'#2A3245')+ridge([(0,420),(120,360),(220,400),(360,350)],'#1F2533')
 +'<path d="M60 640 C130 560 200 520 230 430" stroke="#3A4152" stroke-width="30" fill="none"/>'
 +runner(200,500,1.4,'#0A0C12'),'#0F1420')
for k,v in S.items():
    import os; os.makedirs(os.path.dirname(k),exist_ok=True); open(k+'.svg','w').write(v)
print(len(S))
