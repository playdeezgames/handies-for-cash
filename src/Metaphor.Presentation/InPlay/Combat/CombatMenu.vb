
Imports Metaphor.Processing
Imports TGGD.Presentation

Friend Class CombatMenu
    Inherits MetaphorPickerMenu

    Private Sub New(context As IDisplayContext, model As IWorldModel, previous As DialogSource)
        MyBase.New(context, model, previous)
    End Sub

    Public Overrides ReadOnly Property PromptText As String
        Get
            Return "Now What?"
        End Get
    End Property

    Protected Overrides ReadOnly Property Launchers As IEnumerable(Of LaunchDelegate)
        Get
            Return Enumerable.Empty(Of LaunchDelegate).
                Append(AddressOf ChooseStrongAttack).
                Append(AddressOf ChooseFastAttack).
                Append(AddressOf ChooseParry).
                Append(AddressOf ChooseDodge).
                Append(AddressOf ChooseRest)
        End Get
    End Property

    Private Function ChooseRest(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As IDialogChoice
        Return DialogChoice.Create(True, "Rest", CombatRestActivity.Launch(context, model, previous))
    End Function

    Private Function ChooseDodge(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As IDialogChoice
        Return DialogChoice.Create(model.Avatar.Combat.CanDodge, "Dodge", CombatDodgeActivity.Launch(context, model, previous))
    End Function

    Private Function ChooseParry(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As IDialogChoice
        Return DialogChoice.Create(model.Avatar.Combat.CanParry, "Parry", CombatParryActivity.Launch(context, model, previous))
    End Function

    Private Function ChooseFastAttack(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As IDialogChoice
        Return DialogChoice.Create(model.Avatar.Combat.CanFastAttack, "Fast Attack", CombatFastAttackActivity.Launch(context, model, previous))
    End Function

    Private Function ChooseStrongAttack(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As IDialogChoice
        Return DialogChoice.Create(model.Avatar.Combat.CanStrongAttack, "Strong Attack", CombatStrongAttackActivity.Launch(context, model, previous))
    End Function

    Friend Shared Function Launch(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As DialogSource
        Return Function() New CombatMenu(context, model, previous)
    End Function
End Class
