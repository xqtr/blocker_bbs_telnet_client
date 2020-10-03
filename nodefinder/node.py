#!/usr/bin/python3

import os, sys

bbs = ''
zone = ''
region = ''
host = ''

colors = {
 'r':"\033[0m",
  0:"\033[0;30m",
  1:"\033[0;34m",
  2:"\033[0;32m",
  3:"\033[0;36m",
  4:"\033[0;31m",
  5:"\033[0;35m",
  6:"\033[0;33m",
  7:"\033[0;37m",
  8:"\033[1;30m",
  9:"\033[1;34m",
  10:"\033[1;32m",
  11:"\033[1;36m",
  12:"\033[1;31m",
  13:"\033[1;35m",       
  14:"\033[1;33m",
  15:"\033[1;37m",
  16:"\033[40m",
  17:"\033[44m",
  18:"\033[42m",
  19:"\033[46m",
  20:"\033[41m",
  21:"\033[45m",
  22:"\033[43m",      
  23:"\033[47m"
}

c = colors


box11=(c[7]+'■',c[11]+'▀',c[15]+'■',c[11]+'▌',c[3]+'▐',c[15]+'■',c[3]+'▄',c[8]+'■',c[16]+' ')

textattr = colors[7]+colors[16]

def gotoxy(x,y):
  if x < 1:
    x = 1
  if x > 80:
    x = 80
  if y<1:
    y = 1
  if y>25:
    y=25
  sys.stdout.write('\033['+str(y)+';'+str(x)+'H')
  sys.stdout.flush()

def write(s):
  global textattr
  sys.stdout.write(textattr)
  sys.stdout.flush()
  os.write(1,bytes(s,"CP437"))
  
def writexy(x,y,s):
  gotoxy(x,y)
  write(s)
  
def cursorleft(n):
  sys.stdout.write('\033['+str(n)+'D')
  sys.stdout.flush()
  
def ansibox(x1,y1,x2,y2,box):
    gotoxy(x1,y1)
    #swrite(box[0]+box[1]*(x2-x1-1)+box[2])
    write(box[0]+box[1]*(x2-x1-1)+box[2])
    gotoxy(x1,y2)
    #swrite(box[5]+box[6]*(x2-x1-1)+box[7])
    write(box[5]+box[6]*(x2-x1-1)+box[7])
    for i in range(y2-y1-1):
        gotoxy(x1,y1+1+i)
        #swrite(box[3]+box[8]*(x2-x1-1)+box[4])
        write(box[3]+box[8]*(x2-x1-1)+box[4])

def findnodefiles():
  res = []
  for i in os.listdir(sys.path[0]):
    if i != 'node.py':
      res.append(i)
  return res

def findbbsnode(node):
  global zone, region, host
  global textattr
  n = ''
  found = False
  
  for fn in findnodefiles():
    if found:
      break
    write('\nSearching file: '+fn+'...\n')
    
    cnt=0
    f = open(sys.path[0]+os.sep+fn, 'r')
    text = f.readlines()
    for line in text:
      cursorleft(30)
      cnt +=1
      #write('Line '+str(cnt)+'/'+str(len(text)))
      if line[0] == ';':
        continue
      else:
        csv = line.split(',')
        if csv[0].upper() == 'ZONE':
          zone =  csv[1]
        elif csv[0].upper() == 'HOST' or csv[0].upper() == 'REGION':
          region = csv[1]
        elif  csv[0] == '':
          host = csv[1]
          for field in csv:
            if 'INA:' in field :
              a = field.split(':')
              bbs = a[1]
          for field in csv:
            if 'ITN' in field and ':' in field:
              a = field.split(':')
              bbs = bbs + ':'+a[1]
          location = csv[3].replace('_',' ')
          sysop = csv[4].replace('_',' ')
          n = zone + ':' + region + '/' + host
          #write(n+'\n')
          if node == n:
            textattr = colors[3]+colors[16]
            x = 5
            ansibox(3,6,77,15,box11)
            writexy(x,8, '    Node : ')
            writexy(x,9, '    Name : ')
            writexy(x,10,' Address : ')
            writexy(x,11,'Location : ')
            writexy(x,12,'   Sysop : ')
            textattr = colors[11]+colors[16]
            writexy(x+11,8,n)
            writexy(x+11,9,csv[2].replace('_',' '))
            writexy(x+11,10,bbs.replace('\n',''))
            writexy(x+11,11,location)
            writexy(x+11,12,sysop)
            textattr = colors[3]
            writexy(28,14,'Press a key to continue...')
            found = True
            break
          
          else:
            bbs = ''
          
    f.close()
  if not found:
    ansibox(26,5,54,11,box11)
    textattr = colors[15]
    writexy(33,7,'No BBS found.')
    textattr = colors[3]
    writexy(28,9,'Press a key to continue...')
    
      
  

findbbsnode(sys.argv[1])


