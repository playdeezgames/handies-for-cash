Public Interface IAvatarCombatModel
    ReadOnly Property InCombat As Boolean
    ReadOnly Property CanDodge As Boolean
    ReadOnly Property CanParry As Boolean
    ReadOnly Property CanFastAttack As Boolean
    ReadOnly Property CanStrongAttack As Boolean
    Sub StrongAttack()
    Sub Rest()
    Sub Parry()
    Sub FastAttack()
    Sub Dodge()
End Interface
