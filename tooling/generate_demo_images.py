"""Create original geometric placeholders. Standard library only; no external art."""
import json, math, struct, zlib
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
BLUE=(18,80,196); INK=(16,40,82); PALE=(196,214,250); WHITE=(255,255,255)
class Canvas:
    def __init__(self,w,h,seed):
        self.w,self.h=w,h
        self.rows=[]
        for y in range(h):
            t=y/max(1,h-1)
            color=tuple(round(a+(b-a)*t) for a,b in zip((244,246,250),(220,232,255)))
            self.rows.append(bytearray(bytes(color)*w))
        self.rect(w*.06,h*.08,w*.94,h*.09,PALE)
        self.circle(w*.85,h*.22,h*.09,PALE)
        self.circle(w*.15,h*.83,h*.07,PALE)
        self.rect(w*.09,h*.91,w*(.35+.02*seed),h*.915,BLUE)
    def rect(self,x0,y0,x1,y1,color):
        x0,x1=max(0,int(x0)),min(self.w,int(x1))
        if x1<=x0:return
        pixels=bytes(color)*(x1-x0)
        for y in range(max(0,int(y0)),min(self.h,int(y1))):self.rows[y][x0*3:x1*3]=pixels
    def circle(self,x,y,r,color):
        for row in range(max(0,int(y-r)),min(self.h,int(y+r)+1)):
            half=math.sqrt(max(0,r*r-(row-y)**2))
            self.rect(x-half,row,x+half,row+1,color)
    def line(self,x0,y0,x1,y1,width,color):
        steps=max(1,int(max(abs(x1-x0),abs(y1-y0))))
        for i in range(steps+1):
            t=i/steps;x=x0+(x1-x0)*t;y=y0+(y1-y0)*t
            self.rect(x-width/2,y-width/2,x+width/2,y+width/2,color)
    def save(self,path):
        path.parent.mkdir(parents=True,exist_ok=True)
        def chunk(kind,data):return struct.pack('!I',len(data))+kind+data+struct.pack('!I',zlib.crc32(kind+data)&0xffffffff)
        raw=b''.join(b'\x00'+row for row in self.rows)
        path.write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('!2I5B',self.w,self.h,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(raw,9))+chunk(b'IEND',b''))
def illustration(kind,slug,seed,floors=3):
    w,h=(400,400) if kind=='teachers' else (1600,1000)
    c=Canvas(w,h,seed)
    if kind=='teachers':
        c.circle(w*.5,h*.37,h*.13,BLUE)
        c.circle(w*.5,h*.88,h*.27,BLUE)
        c.rect(w*.25,h*.88,w*.75,h*.92,BLUE)
        c.line(w*.37,h*.7,w*.5,h*.85,8,PALE);c.line(w*.63,h*.7,w*.5,h*.85,8,PALE)
    elif kind=='buildings':
        c.rect(w*.26,h*.27,w*.75,h*.76,BLUE)
        c.rect(w*.22,h*.24,w*.79,h*.28,INK)
        for floor in range(floors):
            for col in range(5):
                x=w*(.3+.085*col);y=h*(.34+.12*floor)
                c.rect(x,y,x+w*.045,y+h*.065,WHITE)
        c.rect(w*.475,h*.64,w*.55,h*.76,INK);c.rect(w*.2,h*.76,w*.82,h*.79,INK)
    elif kind=='events':
        c.rect(w*.29,h*.24,w*.71,h*.77,BLUE)
        c.rect(w*.32,h*.39,w*.68,h*.73,WHITE)
        c.rect(w*.36,h*.2,w*.38,h*.3,INK);c.rect(w*.62,h*.2,w*.64,h*.3,INK)
        for i in range(6):
            x=w*(.36+.11*(i%3));y=h*(.45+.15*(i//3))
            c.rect(x,y,x+w*.055,y+h*.08,PALE)
        c.circle(w*.61,h*.64,h*.035,BLUE)
    elif kind=='subjects' and slug in ('dart','mobile'):
        c.rect(w*.38,h*.2,w*.62,h*.81,INK)
        c.rect(w*.4,h*.25,w*.6,h*.74,WHITE)
        c.line(w*.45,h*.43,w*.42,h*.5,10,BLUE);c.line(w*.42,h*.5,w*.45,h*.57,10,BLUE)
        c.line(w*.55,h*.43,w*.58,h*.5,10,BLUE);c.line(w*.58,h*.5,w*.55,h*.57,10,BLUE)
        c.circle(w*.5,h*.775,h*.018,WHITE)
    elif kind=='subjects' and slug=='math':
        c.line(w*.28,h*.75,w*.75,h*.75,12,INK);c.line(w*.28,h*.75,w*.28,h*.24,12,INK)
        for i in range(6):c.rect(w*.35,h*(.32+.065*i),w*.72,h*(.32+.065*i)+2,PALE)
        previous=(w*.3,h*.68)
        for i in range(80):
            t=i/79;point=(w*(.3+.4*t),h*(.7-.4*t*t))
            c.line(*previous,*point,12,BLUE);previous=point
    elif kind=='subjects' and slug=='algorithms':
        nodes=[(.5,.25),(.35,.5),(.65,.5),(.26,.72),(.43,.72),(.73,.72)]
        for a,b in [(0,1),(0,2),(1,3),(1,4),(2,5)]:c.line(w*nodes[a][0],h*nodes[a][1],w*nodes[b][0],h*nodes[b][1],10,BLUE)
        for x,y in nodes:c.circle(w*x,h*y,h*.06,BLUE)
    else:
        # Book/newspaper metaphor fits reading, knowledge and campus news.
        c.rect(w*.28,h*.23,w*.73,h*.78,BLUE)
        c.rect(w*.31,h*.27,w*.7,h*.74,WHITE)
        c.rect(w*.345,h*.32,w*.665,h*.39,PALE)
        for i in range(5):c.rect(w*.345,h*(.45+.045*i),w*(.62 if i%2 else .66),h*(.45+.045*i)+7,BLUE)
        c.rect(w*.64,h*.23,w*.675,h*.45,INK)
    return c
fixture=json.loads((ROOT/'backend/campus_demo.json').read_text('utf-8'))
manifest=[]
for collection,field in [('news','imageUrl'),('events','coverUrl'),('subjects','coverUrl'),('teachers','photoUrl'),('buildings','photoUrl')]:
    for index,item in enumerate(fixture[collection]):
        path=item[field];slug=Path(path).stem
        illustration(collection,slug,index,item.get('floors',3)).save(ROOT/path)
        manifest.append({'file':path,'kind':collection,'label':item.get('title',item.get('name'))})
(ROOT/'assets/images/manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Created {len(manifest)} original PNG placeholders')
