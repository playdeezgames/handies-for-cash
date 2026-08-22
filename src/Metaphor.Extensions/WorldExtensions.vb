Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module WorldExtensions
    <Extension>
    Private Sub CreateBlueRoom(world As IWorld, context As IInitializationContext)
        world.CreateLocation(LocationSubtypes.ABANDONED_HOUSE, "The Abandoned House", context.InitializeAbandonedHouse())
    End Sub
    <Extension>
    Public Sub Initialize(world As IWorld, context As IInitializationContext)
        world.Clear()
        world.CreateBlueRoom(context)
        world.AddMessage("Welcome to Handies for Cash!")
        world.Avatar.Look()
    End Sub
End Module
