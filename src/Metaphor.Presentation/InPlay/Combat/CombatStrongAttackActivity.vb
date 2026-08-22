Imports Metaphor.Processing
Imports TGGD.Presentation

Friend Module CombatStrongAttackActivity
    Friend Function Launch(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As DialogSource
        Return Function()
                   model.Avatar.Combat.StrongAttack()
                   Return InPlay.Launch(context, model, previous).Invoke()
               End Function
    End Function
End Module
