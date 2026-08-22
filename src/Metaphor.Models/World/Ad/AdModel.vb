Imports Metaphor.Persistence

Friend Class AdModel
    Implements IAdModel

    Private ReadOnly world As IWorld

    Private Sub New(world As IWorld)
        Me.world = world
    End Sub

    Public ReadOnly Property InProgress As Boolean Implements IAdModel.InProgress
        Get
            Return world.AdFinish.HasValue
        End Get
    End Property

    Public Sub Show() Implements IAdModel.Show
        world.ClearMessages()
        If world.AdFinish.Value > DateTimeOffset.Now Then
            Dim timeRemaining = world.AdFinish.Value - DateTimeOffset.Now
            world.AddMessage($"Time left in ad break: {timeRemaining.ToString("mm\:ss")}")
            world.AddMessage("(This is a turn based game. As such, this counter will not automatically change. You have to click the OK button to refresh.)")
            world.AddMessage(
            "For all yer umlauting needs! umlaut.fyi",
            New Dictionary(Of String, String) From
            {
                {"ELEMENT_TYPE", "LINK"},
                {"URL", "https://umlaut.fyi/"}
            })
        Else
            world.AddMessage("Ad break is complete! You may return to yer metaphor!")
            Dim avatar = world.Avatar
            world.AdFinish = Nothing
        End If
    End Sub

    Public Sub Start() Implements IAdModel.Start
        world.AdFinish = DateTimeOffset.Now.AddMinutes(2.0)
    End Sub

    Friend Shared Function Create(entity As IWorld) As IAdModel
        Return New AdModel(entity)
    End Function
End Class
