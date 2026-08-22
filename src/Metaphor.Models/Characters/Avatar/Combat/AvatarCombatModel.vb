Imports Metaphor.Extensions
Imports Metaphor.Persistence

Friend Class AvatarCombatModel
    Implements IAvatarCombatModel

    Private avatar As ICharacter

    Private Sub New(avatar As ICharacter)
        Me.avatar = avatar
    End Sub

    Public ReadOnly Property InCombat As Boolean Implements IAvatarCombatModel.InCombat
        Get
            Return avatar.InCombat
        End Get
    End Property

    Public ReadOnly Property CanDodge As Boolean Implements IAvatarCombatModel.CanDodge
        Get
            Return avatar.CanDodge
        End Get
    End Property

    Public ReadOnly Property CanParry As Boolean Implements IAvatarCombatModel.CanParry
        Get
            Return avatar.CanParry
        End Get
    End Property

    Public ReadOnly Property CanFastAttack As Boolean Implements IAvatarCombatModel.CanFastAttack
        Get
            Return avatar.CanFastAttack
        End Get
    End Property

    Public ReadOnly Property CanStrongAttack As Boolean Implements IAvatarCombatModel.CanStrongAttack
        Get
            Return avatar.CanStrongAttack
        End Get
    End Property

    Public Sub StrongAttack() Implements IAvatarCombatModel.StrongAttack
        avatar.World.ClearMessages()
        avatar.DoStrongAttack()
    End Sub

    Public Sub Rest() Implements IAvatarCombatModel.Rest
        avatar.World.ClearMessages()
        avatar.DoRest()
    End Sub

    Public Sub Parry() Implements IAvatarCombatModel.Parry
        avatar.World.ClearMessages()
        avatar.DoParry()
    End Sub

    Public Sub FastAttack() Implements IAvatarCombatModel.FastAttack
        avatar.World.ClearMessages()
        avatar.DoFastAttack()
    End Sub

    Public Sub Dodge() Implements IAvatarCombatModel.Dodge
        avatar.World.ClearMessages()
        avatar.DoDodge()
    End Sub

    Friend Shared Function Create(avatar As ICharacter) As IAvatarCombatModel
        Return New AvatarCombatModel(avatar)
    End Function
End Class
