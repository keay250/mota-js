# 地图拼接脚本 By 正灌
#SwapMap.swap(地图1ID,左上角X,左上角Y,地图2ID,左上角X,左上角Y,长,宽,模式)
#模式0为直接交换，1为水平翻转，2为垂直翻转
#仅供参考，禁止盗用

module SwapMap
 module_function
def swap(id1,x1,y1,id2,x2,y2,width,height,kind=0)
  #0不变 1水平翻转 2垂直翻转
  Graphics.freeze
  @kind=kind
  @width=width
  @height=height
  @x1=x1;@x2=x2;@y1=y1;@y2=y2
  $movedevents={} if $movedevents==nil
  if $new_map[id1]==nil
    map1 = load_data(sprintf("Data/Map%03d.rxdata", id1))
  else
    map1 = $new_map[id1]
  end
  if $new_map[id2]==nil
    map2 = load_data(sprintf("Data/Map%03d.rxdata", id2))
  else
    map2 = $new_map[id2]
  end
  
  tmp1 = map1.data.clone
  tmp2 = map2.data.clone
  for i in 0...width
    for j in 0...height
      for k in 0...3
        map1.data[x1+i,y1+j,k]=tmp2[setx(x2+i,2),sety(y2+j,2),k]
        map2.data[x2+i,y2+j,k]=tmp1[setx(x1+i,1),sety(y1+j,1),k]
      end
    end
  end
  
  feb=["A","B","C","D"]
  sevent1=[nil]
  selfsw1={}
  var411=[]
  for i in map1.events.keys
    event=map1.events[i]
    if $movedevents.include?(id1)
      j=event.id
      if $movedevents[id1][j]!=nil
        event.x=$movedevents[id1][j][0]
        event.y=$movedevents[id1][j][1]
        $movedevents[id1].delete_at(j)
        break
      end
    end
    x=event.x
    y=event.y
    if x>=x1 && x<x1+width && y>=y1 && y<y1+height
      sevent1.push(event.clone)
      for q in feb
        if $game_self_switches[[id1,i,q]]
          selfsw1[[id1,i,q]]=true
          $game_self_switches.delete([id1,i,q])
        end
      end
      if $game_variables[41][id1]!=nil
        for ii in $game_variables[41][id1]
          if !ii.is_a?(Integer)
            chk=ii[0]
          else
            chk=ii
          end
          if chk==i
            var411.push(ii)
            $game_variables[41][id1].delete(ii)
            if $game_variables[41][id1].size==0
              $game_variables[41].delete(id1)
            end
          end
        end
      end
      map1.events.delete(i)
    end
  end
  sevent2=[nil]
  selfsw2={}
  var412=[]
  for i in map2.events.keys
    event=map2.events[i]
    if $movedevents.include?(id2)
      j=event.id
      if $movedevents[id2][j]!=nil
        event.x=$movedevents[id2][j][0]
        event.y=$movedevents[id2][j][1]
        $movedevents[id2].delete_at(j)
        break
      end
    end
    x=event.x
    y=event.y
    if x>=x2 && x<x2+width && y>=y2 && y<y2+height
      sevent2.push(event.clone)
      for q in feb
        if $game_self_switches[[id2,i,q]]
          selfsw2[[id2,i,q]]=true
          $game_self_switches.delete([id2,i,q])
        end
      end
      if $game_variables[41][id2]!=nil
        for ii in $game_variables[41][id2]
          if !ii.is_a?(Integer)
            chk=ii[0]
          else
            chk=ii
          end
          if chk==i
            var412.push(ii)
            $game_variables[41][id2].delete(ii)
            if $game_variables[41][id2].size==0
              $game_variables[41].delete(id2)
            end
          end
        end
      end
      map2.events.delete(i)
    end
  end
  i=1;j=1
  change={}
  while i<sevent1.size
    while map2.events[j]!=nil
      j+=1
    end
    map2.events[j]=sevent1[i].clone
    map2.events[j].id=j
    map2.events[j].x+=x2-x1
    map2.events[j].y+=y2-y1
    map2.events[j].x=setx(map2.events[j].x,2)
    map2.events[j].y=sety(map2.events[j].y,2)
    change[sevent1[i].id]=j
    for q in feb
      if selfsw1[[id1,sevent1[i].id,q]]
        $game_self_switches[[id2,j,q]]=true
      end
    end
    i+=1
  end
  for i in var411
    if !i.is_a?(Integer)
      i[0]=change[i[0]]
    else
      i=change[i]
    end
  end
  
  i=1;j=1
  change={}
  while i<sevent2.size
    while map1.events[j]!=nil
      j+=1
    end
    map1.events[j]=sevent2[i].clone
    map1.events[j].id=j
    map1.events[j].x+=x1-x2
    map1.events[j].y+=y1-y2
    map1.events[j].x=setx(map1.events[j].x,1)
    map1.events[j].y=sety(map1.events[j].y,1)
    change[sevent2[i].id]=j
    for q in feb
      if selfsw2[[id2,sevent2[i].id,q]]
        $game_self_switches[[id1,j,q]]=true
      end
    end
    i+=1
  end
  for i in var412
    if !i.is_a?(Integer)
      i[0]=change[i[0]]
    else
      i=change[i]
    end
  end
  if $game_variables[41][id2]==nil
    $game_variables[41][id2]=[]
  end
  $game_variables[41][id2]+=var411
  if $game_variables[41][id1]==nil
    $game_variables[41][id1]=[]
  end
  $game_variables[41][id1]+=var412

  $new_map[id1]=map1
  $new_map[id2]=map2
end

def setx(x,id)
  case @kind
  when 1
    if id==1
      x=@x1*2+@width-1-x
    else
      x=@x2*2+@width-1-x
    end
  end
  return x
end
def sety(y,id)
  case @kind
  when 2
    if id==1
      y=@y1*2+@height-1-y
    else
      y=@y2*2+@height-1-y
    end
  end
  return y
end

def endevent(id1,x1,y1,id2,x2,y2,width,height)
  if $new_map[id1]==nil
    map1 = load_data(sprintf("Data/Map%03d.rxdata", id1))
  else
    map1 = $new_map[id1]
  end
  if $new_map[id2]==nil
    map2 = load_data(sprintf("Data/Map%03d.rxdata", id2))
  else
    map2 = $new_map[id2]
  end
  a={}
  for i in map1.events.keys
    event=map1.events[i]
    j=event.id
    if event.x>=x1 && event.x<x1+width && event.y>=y1 && event.y<y1+height
      a[[event.x-x1,event.y-y1]]=$game_self_switches[[id1,j,"A"]]
    end
  end
  for i in map2.events.keys
    event=map2.events[i]
    j=event.id
    if event.x>=x2 && event.x<x2+width && event.y>=y2 && event.y<y2+height
      $game_self_switches[[id2,j,"A"]]=a[[event.x-x2,event.y-y2]]
    end
  end
end

end