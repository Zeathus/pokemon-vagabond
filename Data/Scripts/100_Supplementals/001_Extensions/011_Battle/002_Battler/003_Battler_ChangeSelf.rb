class Battle::Battler

  alias sup_pbRecoverHP pbRecoverHP

  def pbRecoverHP(amt, anim = true, anyAnim = true)
    return sup_pbRecoverHP(amt, anim, anyAnim) if self.hp <= @totalhp
    return 0 if !Supplementals::ALLOW_HEALING_WITHIN_LAYER
    hpbars = (self.hp * 1.0 / @totalhp).ceil
    if self.hp + amt > @totalhp * hpbars
      amt = (@totalhp * hpbars) - self.hp
    elsif amt < 1 && self.hp % @totalhp != 0
      amt = 1
    end
    oldhp = self.hp
    self.hp += amt
    raise _INTL("HP less than 0") if self.hp<0
    @battle.scene.pbHPChanged(self, oldhp, anim) if amt > 0
    @droppedBelowHalfHP = false if @hp >= @totalhp / 2
    return amt
  end

end