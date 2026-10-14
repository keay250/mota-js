class Enemy_property
  def enemy_new_pass(q,id)
    @epassskill[q].push(id)
    enemy_gain_pass(q,id)
  end
  def enemy_gain_pass(q,id)
    a=@eskill[q][id].to_s.split("-")
    case id
    when 4 #嗜血本能
      if @eskill[q][id].is_a?(Integer)
        @oldecombo[q]+=@eskill[q][id]
      else
        val=((1-@actor.hprate)*100*@eskill[q][id].to_f).to_i
        @oldecombo[q]+=val
        @eskill[q][id]=val
      end
      @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0 #重定义攻速
    when 5 #上位威压
      a=(1-@eskill[q][id].to_f/100.0)**([@elevel[q]-@mlevel,0].max)
      @ma*=a;@md*=a
    when 6 #闪避
      if @eskill[q][id].to_i>=100
        @emisszero[q]-=1
      else
        @emiss[q]*=(1-@eskill[q][id].to_f/100)
      end
      @firstmiss[q]=1 if @firstmiss[q]<1
    when 14 #皮肤硬化
      @enodamage[q]*=(1-a[0].to_f/100.0)
      @edecdamage[q]+=a[1].to_f
    when 18 #魔法免疫
      @ebkb[q]=1
    when 32 #魔法抗性
      @enomagic[q]*=(1-a[0].to_f/100.0)
      @edecmagic[q]+=a[1].to_f
    when 46 #龙裔血脉
      @enodamage[q]*=(1-a[0].to_f/100.0)
      @enomagic[q]*=(1-a[0].to_f/100.0)
    when 55 #幽魂形态
      @eskill[q][id]=@enodamage[q]
      @enodamage[q]*=0
      @enomagic[q]*=2
    when 153 #不朽之力
      val=1-a[0].to_f/100.0
      @enodamage[q]*=val
      @enomagic[q]*=val
    when 191 #刚毅不屈
      @eskill[q][id]=a[0]+"-"+@md.to_s
      @ed[q]+=@md*a[0].to_f/100
    when 203 #海妖外壳
      @edecdamage[q]+=a[0].to_f
    end
  end
  def enemy_lose_pass(q,id)
    a=@eskill[q][id].to_s.split("-")
    case id
    when 4 #嗜血本能
      @oldecombo[q]-=@eskill[q][id]
      @ecombo[q]=Math.sqrt([@oldecombo[q],0].max)/10.0 #重定义攻速
    when 5 #上位威压
      a=(1-@eskill[q][id].to_f/100.0)**([@elevel[q]-@mlevel,0].max)
      @ma/=a;@md/=a
    when 6 #闪避
      if @eskill[q][id].to_i>=100
        @emisszero[q]+=1
      else
        @emiss[q]/=(1-@eskill[q][id].to_f/100)
      end
      @firstmiss[q]=0 if @firstmiss[q]==1
    when 14 #皮肤硬化
      @enodamage[q]/=(1-a[0].to_f/100.0)
      @edecdamage[q]-=a[1].to_f
    when 18 #魔法免疫
      @ebkb[q]=0
    when 32
      @enomagic[q]/=(1-a[0].to_f/100.0)
      @edecmagic[q]-=a[1].to_f
    when 46 #龙裔血脉
      @enodamage[q]/=(1-a[0].to_f/100.0)
      @enomagic[q]/=(1-a[0].to_f/100.0)
    when 55 #幽魂形态
      @enodamage[q]=@eskill[q][id]
      @enomagic[q]/=2
    when 153 #不朽之力
      val=1-a[0].to_f/100.0
      @enodamage[q]/=val
      @enomagic[q]/=val
    when 191 #刚毅不屈
      @ed[q]=a[1].to_f
    when 203 #海妖外壳
      @edecdamage[q]-=a[0].to_f
    end
  end
  # 恩赐解脱
  def groupDeGrace(q)
    a=@eskill[q][206].split("-")
    t=[@ea[q]-@md,0].max*@ecombo[q]*@emakedamage[q]*@mphysicaldef
    if @etd==nil && @turncount<a[2].to_i
      b=1
    else 
      b=a[0].to_f/100
    end
    d=t*(1-b)*@mshield*player_miss(q)+t*b*a[1].to_f
    return d
  end
end