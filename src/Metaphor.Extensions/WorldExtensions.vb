Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module WorldExtensions
    <Extension>
    Friend Sub RespawnEnemies(world As IWorld)
        For Each spawner In world.GetYokage(Yokages.SPAWNERS).Select(Function(x) world.GetFeature(x))
            Dim verb = spawner.Verbs.Single(Function(x) x.EntitySubtype = VerbSubtypes.RESPAWN)
            verb.Perform(spawner, Nothing)
        Next
    End Sub
    <Extension>
    Private Sub CreateBlueRoom(world As IWorld, context As IInitializationContext)
        world.CreateLocation(LocationSubtypes.BLUE_ROOM, "The Blue Room", context.InitializeBlueRoom())
    End Sub
    <Extension>
    Public Sub Initialize(world As IWorld, context As IInitializationContext)
        world.Clear()
        world.CreateBlueRoom(context)
        world.RespawnEnemies()
        world.AddMessage("Welcome to Clumsy Oaf of SPLORR!!")
        world.Avatar.Look()
    End Sub
End Module
