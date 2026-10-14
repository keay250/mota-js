class Enemy_property
    #处理特殊的战斗
  def hasika(q) #狂战士之血
    return false if @mtd[q]<=0
    a=@eskill[q][104].split("-")
    blood=a[2].to_f/100
    l=(@ehp[q]/@mtd[q]).to_i+1
    l-=1 if l*@mtd[q]>=@ehp[q]
    l=0 if l<0
    combo=@oldecombo[q]+100*a[0].to_f
    combo=Math.sqrt([combo,0].max)/10.0
    #无视该被动存在时的数值
    @ea[q]=$data_enemies[@elist[q]].atk
    mtd=@mtd[q]-[ephysicaldam(q,@ea[q]*(1+a[1].to_f)-@md),0].max*combo*@ecrit[q]*player_miss(q)*@emakedamage[q]*blood    
    return false if mtd<0
    r=(@ehp[q]/mtd).to_i+1
    r-=1 if r*mtd>=@ehp[q]
    r=0 if r<0
    return false if r>500
    i=0
    while @ehp[q]>0
      @turncount+=1
      @ehp[q]-=@mtd[q]
      self.edamage-=mrecover(@mhpre)
      self.edamage-=mrecover2((mturn_damage(q)-mtd_extra(q))*@mvampire)
      if @ehp[q]<=0
        enemy_dead(q)
        next
      end
      combo=@oldecombo[q]+(1-@ehp[q].to_f/@emaxhp[q])*100*a[0].to_f
      combo=Math.sqrt([combo,0].max)/10.0
      dam=[ephysicaldam(q,@ea[q]*(1+a[1].to_f*(1-@ehp[q].to_f/@emaxhp[q]))-@md),0].max*combo*@ecrit[q]*player_miss(q)*@emakedamage[q]
      self.edamage+=dam
      @ehp[q]+=erecover(q,dam*blood)
      if @mequip.include?(50) #先锋盾二阶的骨火
        dam=[40*combo,@ehp[q]].min
        @ehp[q]-=dam
        self.edamage-=mrecover2(dam)
      end
      i+=1
    end
    @ehp[q]=0
    return true
  end
end
