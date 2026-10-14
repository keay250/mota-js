def speical_boss(id)
  return if $game_temp.message_window_showing || $game_system.map_interpreter.running?
  @value=$game_variables[252]
  if Kboard.trigger?($R_Key_ALT)
  #  $game_switches[173]=!$game_switches[173]
  end
  case @value[0] #种类
  when 11 #第八章BOSS一阶段
    ev=$game_map.events[5]
    pl=$game_player
    xx=ev.real_x
    yy=ev.real_y
    px=$game_player.real_x
    py=$game_player.real_y
    time=@value[1]%1700
    if @value[1]==20
      $game_switches[174]=false
    end
    if time==20
      new_anima(px,py,87,9)
    end
    if time>=40 && time<218
      time2=(time-40)%120
      if time2==0
        new_anima(xx,yy,29,0)
      end
      if time2==20
        ppx=$game_player.x
        ppy=$game_player.y
        c1=[0,-1,1,0]
        c2=[1,0,0,-1]
        count=0
        while true
          d=rand(4)
          if $game_player.passable?(ppx+c1[d]*5,ppy+c2[d]*5,d*2+2) || count>20
            ev.moveto(ppx+c1[d]*5,ppy+c2[d]*5)
            ev.set_direction(10-(d*2+2))
            break
          end
          count+=1
        end
      end
      if time2==21
        new_anima(xx,yy,30,0)
      end
      if time2==40
        a=RPG::MoveRoute.new
        a.list=[]
        a.list.push(RPG::MoveCommand.new(37,[]))
        a.list.push(RPG::MoveCommand.new(12,[]))
        a.list.push(RPG::MoveCommand.new(12,[]))
        a.list.push(RPG::MoveCommand.new(12,[]))
        a.list.push(RPG::MoveCommand.new(12,[]))
        a.list.push(RPG::MoveCommand.new(12,[]))
        a.list.push(RPG::MoveCommand.new(12,[]))
        a.list.push(RPG::MoveCommand.new(38,[]))
        a.list.push(RPG::MoveCommand.new(0,[]))
        a.repeat=false
        ev.move_route_forcing=true
        ev.force_move_route(a) 
        ev.animation_id=89
      end
      if time2>=41 && time2<=57
        if (pl.x-ev.x).abs<=1 && (pl.y-ev.y).abs<=1
          $game_player.animation_id=47
          damage=10000000
          if damage>=$game_actors[1].hp
            $game_variables[19]=1
            $game_actors[1].hp-=damage
            $game_temp.common_event_id =12#生命小于0，调用1号结局
          else
            $game_actors[1].hp-=damage
          end
        end
      end
      if time2==90
        px=$game_player.real_x
        py=$game_player.real_y
        @value[2]=[px,py]
        new_anima(px-256,py,87,9)
        new_anima(px+256,py,87,9)
        new_anima(px,py-256,87,9)
        new_anima(px,py+256,87,9)
      end
      if time2==96
        px=@value[2][0]
        py=@value[2][1]
        new_anima(px-384,py-384,87,9)
        new_anima(px+384,py-384,87,9)
        new_anima(px+384,py+384,87,9)
        new_anima(px-384,py+384,87,9)
        new_anima(px-512,py,87,9)
        new_anima(px+512,py,87,9)
        new_anima(px,py-512,87,9)
        new_anima(px,py+512,87,9)
      end
    end
    if time>=260 && time<960
      time2=time-260
      if time2==0
        ev.set_direction(2)
      end
      if time2%6==0
        Audio.se_play("Audio/SE/se_tan00",30)
        fllow=bullet_fllow(xx,yy,px,py)
        for j in 0...3
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(32,96,32,32),xx,yy,5,1,1,
            fllow+60+j*30,6.0,0,30000000])
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(32,96,32,32),xx,yy,5,1,1,
            fllow-60-j*30,6.0,0,30000000])
        end
        for j in 0...3
          a=rand(1200)/10.0-60
          b=rand(300)/100.0
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(32,16,16,16),xx,yy,3,1,1,
          fllow+a,4+b,0,5000000])
        end
      end
      if time2%60==50
        fllow=bullet_fllow(xx,yy,px,py)
        for j in -1...2
          for k in -5...6
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(64,96,32,32),xx,yy,7,1,1,
            fllow+j*60+k*3,2.5,0,15000000])
          end
        end
      end
      if time2>=240 && time2%120==60 
        new_anima(px,py,87,9)
      end
    end
    if time==1000
      new_anima(xx,yy,29,0)
    end
    if time==1020
      ev.moveto(17,14)
      ev.set_direction(2)
    end
    if time==1021
      new_anima(xx,yy,30,0)
    end
    if time==1040
      @value[2]=rand(2)
      $game_map.events[7+@value[2]].animation_id=48
      $game_screen.pictures[17].show("specialBOSStip1", 1,
      400,110, 100,100, 255,0)
    end
    if time>=1040 && time<=1150 && time%40==0
      Audio.se_play("Audio/SE/se_power1",70)
      new_anima(xx,yy,91,0)
    end
    if time==1150
      $game_screen.pictures[17].erase
    end
    if time==1160
      event=$game_map.events[7+@value[2]]
      if ($game_player.x-event.x).abs<=1 && $game_player.y<=event.y
        event.animation_id=92
        @value[3]=0
      else
        @value[3]=1
      end
      $game_map.events[2].animation_id=90
    end
    if @value[3]==1 && time>=1160 && time<=1180
      $game_player.animation_id=47
      damage=30000000
      if damage>=$game_actors[1].hp
        $game_variables[19]=1
        $game_actors[1].hp-=damage
        $game_temp.common_event_id =12#生命小于0，调用1号结局
      else
        $game_actors[1].hp-=damage
      end
    end
    if time==1210
      ev.animation_id=94
    end
    if time>=1220 && time<=1600 && (time-1220)%78==0
      if time>=1500
        new_anima(xx,yy,93,11)
      else
        new_anima(xx,yy,93,10)
      end
    end
    if time==1240
      @value[2]=0
      ev.setmovetype(2)
      ev.setspeed(4)
    end
    if time==1605
      xxx=(xx-px).abs/4.0
      yyy=(yy-py).abs/4.0
      if xxx*xxx+yyy*yyy<=10000 
        new_anima(px,py,95,0)
        $game_variables[289]=100
        damage=40000000
        if damage>=$game_actors[1].hp
          $game_variables[19]=1
          $game_actors[1].hp-=damage
          $game_temp.common_event_id =12#生命小于0，调用1号结局
        else
          $game_actors[1].hp-=damage
        end
      end
    end
    if time>=1241 && time<=1620
      if @value[2]==0
        if ((pl.x-ev.x).abs<=1 && (pl.y-ev.y).abs<=3) ||
          ((pl.x-ev.x).abs<=3 && (pl.y-ev.y).abs<=1)
          ev.turn_toward_player
          ev.setmovetype(0)
          ev.setspeed(5)
          a=RPG::MoveRoute.new
          a.list=[]
          a.list.push(RPG::MoveCommand.new(37,[]))
          a.list.push(RPG::MoveCommand.new(12,[]))
          a.list.push(RPG::MoveCommand.new(12,[]))
          a.list.push(RPG::MoveCommand.new(12,[]))
          a.list.push(RPG::MoveCommand.new(12,[]))
          a.list.push(RPG::MoveCommand.new(38,[]))
          a.list.push(RPG::MoveCommand.new(0,[]))
          a.repeat=false
          ev.move_route_forcing=true
          ev.force_move_route(a) 
          ev.animation_id=89
          @value[2]=100
          ev.trg_x=0
          ev.trg_y=0
        end
        if (pl.x-ev.x).abs+(pl.y-ev.y).abs>=14
          new_anima(xx,yy,29,0)
          @value[2]=50
        end
      else
        if @value[2]>=83
        if (pl.x-ev.x).abs<=1 && (pl.y-ev.y).abs<=1
          $game_player.animation_id=47
          damage=10000000
          if damage>=$game_actors[1].hp
            $game_variables[19]=1
            $game_actors[1].hp-=damage
            $game_temp.common_event_id =12#生命小于0，调用1号结局
          else
            $game_actors[1].hp-=damage
          end
        end
      end
        @value[2]-=1 if @value[2]>0
        if @value[2]==60
          if !$game_player.passable?(ev.x,ev.y,2)
            new_anima(xx,yy,29,0)
            @value[2]=50
          end
          if @value[2]==60
            ev.setmovetype(2)
            ev.setspeed(4)
            @value[2]=0
          end
        end
      end
      if @value[2]==40
        ev.moveto(pl.x,pl.y-1)
        ev.set_direction(2)
      end
      if @value[2]==39
        new_anima(xx,yy,30,0)
      end
      if @value[2]==27
        ev.setmovetype(2)
        ev.setspeed(4)
        @value[2]=0
      end
    end
    if time==1650
      ev.setmovetype(0)
      ev.setspeed(5)
    end
    
    if $game_variables[244]<=0
      $game_screen.pictures[17].erase
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
      $game_switches[175]=true
    end
  when 12 #第八章结束
    $game_variables[244]=0
    if @value[1]==11
      $game_variables[247]=[]
      $game_variables[250]=[]
    end
    if @value[1]==12
      $game_switches[171]=false
      $game_switches[172]=false
      $game_variables[278]=20
    end
  when 1
    xx=$game_map.events[5].real_x
    yy=$game_map.events[5].real_y-192
    time=@value[1]%840
    if time<=600
      time2=time%120
      if time2==0
       # @value[0]=3
        #$game_variables[244]=2100
      end
      if time2>=0 && time2<=66 && time2%3==0
        Audio.se_play("Audio/SE/se_tan00",30)
        for j in 0...3
          x=xx+Math.cos((j*120+time/0.04)/57.3)*48*4
          y=yy+Math.sin((j*120+time/0.04)/57.3)*48*4
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,209,32,30),x,y,1,2,2,0,0,1,0])
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,16,16,16),x,y,10,1,1,j*36+time/0.04,3,0,8000])
        end
        for j in 0...2
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,96,16,16),xx,yy,9,1,1,rand(3600)/10.0,3+rand(50)/50.0,0,8000])
        end
      end
      if time2==90
        new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,209,32,30),xx,yy,1,3,3,0,0,1,0])
        Audio.se_play("Audio/SE/se_tan00",40)
        a=rand(80)/10.0
        if time>=480
          bit=RPG::Cache.picture("bullet2")
          rect=Rect.new(96,32,32,32)
          dam=150000
        else
          bit=RPG::Cache.picture("bullet1")
          rect=Rect.new(96,48,16,16)
          dam=30000
        end
        for j in 0...45
          new_bullet([bit,rect,xx,yy,9,1,1,a+j*8,3+j%2,0,dam])
        end
      end
    end
    if time>=640 && time<=800
      time2=time-640
      if time2<=36 && time2%2==0
        new_bullet([RPG::Cache.picture("bullet1"),Rect.new(32,209,32,30),xx,yy,1,2,2,0,0,1,0])
        Audio.se_play("Audio/SE/se_tan00",30)
        a=rand(40)/10.0
        for j in 0...12
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(32,80,16,16),xx,yy,10,1,1,j*30+time2*3+a,2+time2/9.0,0,8000])
        end
      end
      if time2>=90 && time2<=126 && time2%2==0
        new_bullet([RPG::Cache.picture("bullet1"),Rect.new(160,209,32,30),xx,yy,1,2,2,0,0,1,0])
        Audio.se_play("Audio/SE/se_tan00",30)
        a=rand(40)/10.0
        for j in 0...12
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(160,80,16,16),xx,yy,10,1,1,j*30-time2*3+a,2+(time2-90)/9.0,0,8000])
        end
      end
    end
    if $game_variables[244]*100.0/$game_variables[245]<=75
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
    end
  when 2
    xx=$game_map.events[5].real_x
    yy=$game_map.events[5].real_y-192
    if @value[1]==20
      Audio.se_play("Audio/SE/se_power1",100)
    end
    if @value[1]<60
      $game_variables[244]=($game_variables[245]*0.75).to_i
    end
    if @value[1]>=60
      time=(@value[1]-60)%1000
      if time==0
        $game_switches[174]=false
      end
      if time<=520
        if time%40==0
          px=$game_player.real_x
          py=$game_player.real_y
          new_anima(px,py,46,4)
        end
        if time>=200 && time<520
          time2=(time-200)%160
          if time2==0
            Audio.se_play("Audio/SE/se_power1",100)
          end
          if time2>=30 && time2<60 && time2%6==0
            px=$game_player.real_x
            py=$game_player.real_y-24
            fllow=bullet_fllow(xx,yy,px,py)+rand(100)/10.0-5
            Audio.se_play("Audio/SE/se_tan02",80)
            new_bullet([RPG::Cache.picture("bullet1"),Rect.new(128,209,32,30),xx,yy,1,3,3,0,0,1,0])
            for j in 0...10
              new_bullet([RPG::Cache.picture("bullet2"),Rect.new(128,64,32,32),xx,yy,10,1,1,fllow,1.5+j*0.8,0,20000])
              new_bullet([RPG::Cache.picture("bullet2"),Rect.new(128,64,32,32),xx,yy,10,1,1,fllow+45,1.5+j*0.8,0,20000])
              new_bullet([RPG::Cache.picture("bullet2"),Rect.new(128,64,32,32),xx,yy,10,1,1,fllow-45,1.5+j*0.8,0,20000])
            end
          end
        end
      end
      if time==520
        @value[2]=40
        @value[3]=0
      end
      if time>=520
        time2=(time-520)
        if time<=850
          if time<=820 && time2%20==0
            px=$game_player.real_x
            py=$game_player.real_y-24
            fllow=bullet_fllow(xx,yy,px,py)+rand(100)/10.0-5
            Audio.se_play("Audio/SE/se_tan02",60)
            new_bullet([RPG::Cache.picture("bullet1"),Rect.new(128,209,32,30),xx,yy,1,3,3,0,0,1,0])
            for j in 0...24
              new_bullet([RPG::Cache.picture("bullet2"),Rect.new(128,64,32,32),xx,yy,10,1,1,fllow+j*15,3,0,20000])
            end
          end
          @value[3]+=1
          if @value[3]>=[@value[2],10].max
            @value[3]=0
            px=$game_player.real_x
            py=$game_player.real_y
            new_anima(px,py,46,4)
            @value[2]-=3
          end
        end
      end
      if time2==880
        Audio.se_play("Audio/SE/se_power1",100)
      end
      if time>=900 && time<=940 && time%20==0
        a=rand(3600)/10.0
        Audio.se_play("Audio/SE/se_tan01",90)
        for j in 0...20
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(64,192,64,64),xx,yy,8,1,1,a+j*18,3,0,80000])
        end
      end
    end
    if $game_variables[244]*100.0/$game_variables[245]<=50
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
    end
  when 3
    xx=$game_map.events[5].real_x
    yy=$game_map.events[5].real_y-192
    if @value[1]==20
      Audio.se_play("Audio/SE/se_power0",100)
    end
    if @value[1]<60
      $game_variables[244]=($game_variables[245]*0.5).to_i
    end
    if @value[1]>=60
      time=@value[1]-60
      if time==0
        $game_switches[174]=false
      end
      if time%40==0
        new_anima(xx,yy,48,5)
      end
    end
    if $game_variables[244]*100.0/$game_variables[245]<=25
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
    end
  when 4
    xx=$game_map.events[5].real_x
    yy=$game_map.events[5].real_y-192
    if @value[1]==20
      Audio.se_play("Audio/SE/se_power0",100)
      $game_variables[243]+=1
      $game_variables[245]=15000
    end
    if @value[1]==80
      Audio.se_play("Audio/SE/se_cat00",100)
      for i in 0...10
        id=new_anima(xx,yy,51,6,99)
        $game_variables[247][id][5]=[xx,yy,i*36,0]
      end
      $game_screen.start_shake(2,25,50)
      $game_variables[254]=1
      @value[2]=290
      @value[3]=0
    end
    if @value[1]<80
      $game_variables[244]=($game_variables[245]*0.25).to_i
    end
    hprate=$game_variables[244]*100.0/$game_variables[245]
    if @value[1]>=80
      time=(@value[1]-80)%1000
      if time==0
        $game_switches[174]=false
      end
      time2=@value[3]
      if time2==0
        l=384
        Audio.se_play("Audio/SE/se_slash",100)
        dam=200000
        new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),xx,yy-l,10,1,1,180,0,2,dam])
        new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),xx,yy+l,10,1,1,180,0,2,dam])
        new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),xx-l,yy,10,1,1,180,0,2,dam])
        new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),xx+l,yy,10,1,1,180,0,2,dam])
        if hprate<=12
          px=$game_player.real_x
          py=$game_player.real_y-24
          fllow=bullet_fllow(xx,yy,px,py)
          for i in 0...5
            nx=px+Math.cos((fllow+i*45+180)%360/57.3)*128*5
            ny=py+Math.sin((fllow+i*45+180)%360/57.3)*128*5
            new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),nx,ny,10,1,1,180,0,2,dam])
          end
        end
      end
      if time2==60
        Audio.se_play("Audio/SE/se_ch00",100)
      end
      if time2==100
        Audio.se_play("Audio/SE/se_slash",100)
        $game_screen.start_shake(2,25,30)
        $game_screen.start_flash($mapdamage_obj.getcolor(2),20)
      end
      @value[3]+=1
      if @value[3]>=@value[2] 
        @value[3]=0
        @value[2]-=30 if @value[2]>130
      end
    end
    if hprate<=0
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
      $game_switches[175]=true
    end
  when 5
    $game_variables[244]=0
    if @value[1]==11
      $game_variables[247]=[]
      $game_variables[250]=[]
    end
    if @value[1]==12
      $game_switches[171]=false
      $game_switches[172]=false
      $game_variables[243]=13
    end
  when 6 #多兰一身
    xx=$game_map.events[4].real_x
    yy=$game_map.events[4].real_y
    if @value[1]==1
      Audio.se_play("Audio/SE/se_power1",100)
    end
    if @value[1]<30
      $game_variables[244]=($game_variables[245]*1).to_i
    end
    if @value[1]>=40
      time=(@value[1]-40)%370
      if time==0
        $game_switches[174]=false
      end
      if time<210 
        if time%40==0
          @value[2]=rand(3600)/10.0 
        end
        if time%40<20 && time%40%4==0
          a=@value[2]
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,209,32,30),xx,yy,1,3,3,0,0,1,0])
          Audio.se_play("Audio/SE/se_tan01",90)
          for j in 0...20
            new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,48,16,16),xx,yy,8,1,1,a+j*18,5,0,100000])
          end
        end
      end
      if time<40 && time%5==0
        px=$game_player.real_x
        py=$game_player.real_y
        l=time/5
        new_anima(xx+128*2*l,yy,46,4)
        new_anima(xx-128*2*l,yy,46,4)
        new_anima(xx,yy+128*2*l,46,4)
        new_anima(xx,yy-128*2*l,46,4)
      end
      if time>=60 && time<100 && time%5==0
        px=$game_player.real_x
        py=$game_player.real_y
        l=(time-60)/5
        dx=128*2*l
        dy=128*2*l
        new_anima(xx-dx,yy-dy,46,4)
        new_anima(xx-dx,yy+dy,46,4)
        new_anima(xx+dx,yy+dy,46,4)
        new_anima(xx+dx,yy-dy,46,4)
      end
      if time>=120 && time<180 && time%10==0
        l=(time-120)/10
        c=[1,4,6,9,10,12]
        aa=360/c[l]
        a=180
        for i in 0...c[l]
          x=xx+Math.cos((a+i*aa)/57.3)*l*80*4
          y=yy+Math.sin((a+i*aa)/57.3)*l*80*4
          new_anima(x,y,46,4)
        end
      end
      
      if time==210 || time==320
        value=$game_map.events[4]
        a=rand(4)
        sx=$game_map.x_with_direction(0, a*2+2)
        sy=$game_map.y_with_direction(0, a*2+2)
        while !$game_player.passable?($game_player.x+sx,$game_player.y+sy,0)
          a=rand(4)
          sx=$game_map.x_with_direction(0, a*2+2)
          sy=$game_map.y_with_direction(0, a*2+2)
        end
        a=RPG::MoveRoute.new
        a.list=[]
        a.list.push(RPG::MoveCommand.new(37,[]))
        a.list.push(RPG::MoveCommand.new(14,[$game_player.x-value.x+sx,$game_player.y-value.y+sy]))
        a.list.push(RPG::MoveCommand.new(25,[]))
        a.list.push(RPG::MoveCommand.new(38,[]))
        a.list.push(RPG::MoveCommand.new(0,[]))
        a.repeat=false
        value.move_route_forcing=true
        value.force_move_route(a) 
      end
      if time==230 || time==330
        Audio.se_play("Audio/SE/se_power1",100)
      end
      if time>=270 && time<=290 && time%10==0
        px=$game_player.real_x
        py=$game_player.real_y-24
        fllow=bullet_fllow(xx,yy,px,py)
        Audio.se_play("Audio/SE/se_tan01",90)
        new_bullet([RPG::Cache.picture("bullet1"),Rect.new(128,209,32,30),xx,yy,1,3,3,0,0,1,0])
        for k in -2...3
        for j in 0...3
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(128,32,32,32),xx,yy,10,1,1,fllow+k*30,4+j*1,0,500000])
        end
        end
      end
    end
    if $game_variables[244]*100.0/$game_variables[245]<=75
      value=$game_map.events[4]
      a=RPG::MoveRoute.new
      a.list=[]
      a.list.push(RPG::MoveCommand.new(37,[]))
      a.list.push(RPG::MoveCommand.new(14,[21-value.x,10-value.y]))
      a.list.push(RPG::MoveCommand.new(16,[]))
      a.list.push(RPG::MoveCommand.new(38,[]))
      a.list.push(RPG::MoveCommand.new(0,[]))
      a.repeat=false
      value.move_route_forcing=true
      value.force_move_route(a) 
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
    end
  when 7 #多兰一符
    xx=$game_map.events[4].real_x
    yy=$game_map.events[4].real_y
    if @value[1]==20
      Audio.se_play("Audio/SE/se_power0",100)
      $game_variables[245]=12000
    end
    if @value[1]==80
      Audio.se_play("Audio/SE/se_cat00",100)
      $game_screen.start_shake(2,25,50)
      $game_variables[254]=2
      $game_switches[174]=false
    end
    if @value[1]<80
      $game_variables[244]=($game_variables[245]*0.75).to_i
    end
    if @value[1]>=80
      time=@value[1]-80
      if time>=0 && time%4==0
        for i in 0...5
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(128,48,16,16),xx,yy,8,1,1,i*72+time*3,4,0,100000])
        end
      end
      if time%30==0
        Audio.se_play("Audio/SE/se_tan02",90)
        a=rand(150)/10.0-7.5
        for i in -12...12
          if i.abs>=2
            for j in 0...3
            new_bullet([RPG::Cache.picture("bullet2"),Rect.new(96,32,32,32),xx,yy,8,1,1,time%720/2+i*15+180+a,4+j,0,500000])
            end
          end
        end
      end
    end
    hprate=$game_variables[244]*100.0/$game_variables[245]
    if hprate<=50
      $game_variables[254]=0
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
    end
  when 8 #多兰二身
    xx=$game_map.events[4].real_x
    yy=$game_map.events[4].real_y
    if @value[1]==1
      Audio.se_play("Audio/SE/se_power1",100)
    end
    if @value[1]<30
      $game_variables[244]=($game_variables[245]*0.5).to_i
    end
    if @value[1]>=40
      time=(@value[1]-40)%480
      if time==0
        $game_switches[174]=false
      end
      if time%60==0
        a=rand(3600)/10.0
        Audio.se_play("Audio/SE/se_tan01",90)
        for j in 0...60
          new_bullet([RPG::Cache.picture("bullet1"),Rect.new(96,48,16,16),xx,yy,8,1,1,a+j*9,5,0,100000])
        end
      end
      if time==20
        dam=2000000
        px=$game_player.real_x
        a=1-px/128%2
        py=$game_player.real_y
        for j in 0...15
          new_anima((7+j*2+a)*128,py,46,4)
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),(7+j*2+a)*128,128,10,1,1,180,0,3,dam])
        end
      end
      if time==180
        dam=2000000
        px=$game_player.real_x
        py=$game_player.real_y
        a=1-py/128%2
        for j in 0...10
          new_anima(px,(5+j*2+a)*128,46,4)
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),720,(5+j*2+a)*128,10,1,1,90,0,3,dam])
        end
      end
      if time==340
        dam=2500000
        px=$game_player.real_x
        a=1-px/128%2
        py=$game_player.real_y
        for j in 0...15
          new_anima((7+j*2+a)*128,py,46,4)
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),(7+j*2+a)*128,25*128,10,1,1,0,0,3,dam])
        end
        a=1-py/128%2
        for j in 0...10
          new_anima(px,(5+j*2+a)*128,46,4)
          new_bullet([RPG::Cache.picture("bullet2"),Rect.new(318,0,66,160),36*128,(5+j*2+a)*128,10,1,1,270,0,3,dam])
        end
      end
      if time==60
        Audio.se_play("Audio/SE/se_slash",100)
      end
      if time==220
        Audio.se_play("Audio/SE/se_slash",100)
      end
      if time==380
        Audio.se_play("Audio/SE/se_slash",100)
      end
      if time==400
        value=$game_map.events[4]
        a=rand(4)
        sx=$game_map.x_with_direction(0, a*2+2)
        sy=$game_map.y_with_direction(0, a*2+2)
        while !$game_player.passable?($game_player.x+sx,$game_player.y+sy,0)
          a=rand(4)
          sx=$game_map.x_with_direction(0, a*2+2)
          sy=$game_map.y_with_direction(0, a*2+2)
        end
        a=RPG::MoveRoute.new
        a.list=[]
        a.list.push(RPG::MoveCommand.new(37,[]))
        a.list.push(RPG::MoveCommand.new(14,[$game_player.x-value.x+sx,$game_player.y-value.y+sy]))
        a.list.push(RPG::MoveCommand.new(25,[]))
        a.list.push(RPG::MoveCommand.new(38,[]))
        a.list.push(RPG::MoveCommand.new(0,[]))
        a.repeat=false
        value.move_route_forcing=true
        value.force_move_route(a) 
      end
      
    end
    if $game_variables[244]*100.0/$game_variables[245]<=25
      value=$game_map.events[4]
      a=RPG::MoveRoute.new
      a.list=[]
      a.list.push(RPG::MoveCommand.new(37,[]))
      a.list.push(RPG::MoveCommand.new(14,[21-value.x,10-value.y]))
      a.list.push(RPG::MoveCommand.new(16,[]))
      a.list.push(RPG::MoveCommand.new(38,[]))
      a.list.push(RPG::MoveCommand.new(0,[]))
      a.repeat=false
      value.move_route_forcing=true
      value.force_move_route(a) 
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
    end
  when 9 #多兰二符
    xx=$game_map.events[4].real_x
    yy=$game_map.events[4].real_y
    if @value[1]==20
      Audio.se_play("Audio/SE/se_power0",100)
      $game_variables[245]=12000
    end
    if @value[1]==80
      Audio.se_play("Audio/SE/se_cat00",100)
      $game_screen.start_shake(2,25,50)
      $game_variables[254]=3
      $game_switches[174]=false
    end
    if @value[1]<80
      $game_variables[244]=($game_variables[245]*0.25).to_i
    end
    if @value[1]>=80
      time=(@value[1]-80)%400
      if time==0
        new_bullet([RPG::Cache.picture("laser"),Rect.new(0,512,512,512),xx,yy,8,0,1,180,0,4,100000])
      end
    end
    hprate=$game_variables[244]*100.0/$game_variables[245]
    if hprate<=0
      @value[0]+=1
      @value[1]=0
      $game_switches[174]=true
      $game_switches[175]=true
    end
  when 10
    $game_variables[244]=0
    if @value[1]==11
      $game_variables[247]=[]
      $game_variables[250]=[]
    end
    if @value[1]==12
      $game_switches[171]=false
      $game_switches[172]=false
      $game_variables[257]=33
    end
  end


  @value[1]+=1 #计时器
end
