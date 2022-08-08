class Battle::Battler
  
  alias sup_initialize initialize

  def initialize(btl, idxBattler)
    @knownMoves   = []
    @knownAbility = false
    @knownItem    = false
    sup_initialize(btl, idxBattler)
  end

end