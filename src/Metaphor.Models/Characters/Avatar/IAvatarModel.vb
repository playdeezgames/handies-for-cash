Public Interface IAvatarModel
    Sub ShowStatus()
    Sub Look()
    Sub Respawn()
    ReadOnly Property Inventory As IInventoryModel
    ReadOnly Property AvailableVerbs As IEnumerable(Of IVerbModel)
    ReadOnly Property DialogMode As String
    ReadOnly Property IsDead As Boolean
    ReadOnly Property Combat As IAvatarCombatModel
End Interface
