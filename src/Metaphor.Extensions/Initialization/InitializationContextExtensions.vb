Imports System.Runtime.CompilerServices
Imports Metaphor.Extensions
Imports Metaphor.Persistence
Imports TGGD.Extensions

Friend Module InitializationContextExtensions
    <Extension>
    Friend Function InitializeBlueRoom(context As IInitializationContext) As Persistence.LocationInitializer
        Return Sub(room)
                   Dim checkpoint = room.CreateCheckpoint()
                   room.CreateN00b(context.ChosenName, context.InitializeN00b(checkpoint))
                   InitializeMaze(room)
               End Sub
    End Function
#Region "Maze"
    Private mazeDirections As New Dictionary(Of String, MazeDirection(Of String)) From
        {
            {Directions.NORTH, New MazeDirection(Of String)(Directions.SOUTH, 0, -1)},
            {Directions.EAST, New MazeDirection(Of String)(Directions.WEST, 1, 0)},
            {Directions.SOUTH, New MazeDirection(Of String)(Directions.NORTH, 0, 1)},
            {Directions.WEST, New MazeDirection(Of String)(Directions.EAST, -1, 0)}
        }
    Private Sub InitializeMaze(room As ILocation)
        Const MAZE_COLUMNS = 4
        Const MAZE_ROWS = 4
        Dim maze As New Maze(Of String)(MAZE_COLUMNS, MAZE_ROWS, mazeDirections)
        maze.Generate()
        Dim world = room.World
        For Each column In Enumerable.Range(0, MAZE_COLUMNS)
            For Each row In Enumerable.Range(0, MAZE_ROWS)
                world.CreateLocation(
                    LocationSubtypes.MAZE,
                    "Maze Room",
                    Sub(location)
                        location.SetCounter(Counters.MAZE_COLUMN, column)
                        location.SetCounter(Counters.MAZE_ROW, row)
                        world.AddToYokage(Yokages.MAZE_LOCATIONS, location.EntityId)
                    End Sub)
            Next
        Next
        Dim mazeLocations = world.GetYokage(Yokages.MAZE_LOCATIONS).Select(AddressOf world.GetLocation)
        For Each column In Enumerable.Range(0, MAZE_COLUMNS)
            For Each row In Enumerable.Range(0, MAZE_ROWS)
                Dim mazeCell = maze.GetCell(column, row)
                Dim mazeLocation = mazeLocations.Single(Function(x) x.GetCounter(Counters.MAZE_COLUMN) = column AndAlso x.GetCounter(Counters.MAZE_ROW) = row)
                For Each direction In mazeDirections.Keys
                    Dim door = mazeCell.GetDoor(direction)
                    If If(door?.Open, False) Then
                        Dim nextColumn = mazeDirections(direction).DeltaX + column
                        Dim nextRow = mazeDirections(direction).DeltaY + row
                        Dim nextLocation = mazeLocations.Single(Function(x) x.GetCounter(Counters.MAZE_COLUMN) = nextColumn AndAlso x.GetCounter(Counters.MAZE_ROW) = nextRow)
                        mazeLocation.CreateDoor(direction, nextLocation)
                    End If
                Next
            Next
        Next
        Dim entrance = RNG.FromEnumerable(mazeLocations)
        room.CreateDoor(Directions.OUT, entrance)
        entrance.CreateDoor(Directions.IN, room)
        PopulateMaze(mazeLocations)
    End Sub
    Private Delegate Sub MazeAreaPopulator(location As ILocation)
    Private mazeAreaPopulators As New Dictionary(Of Integer, MazeAreaPopulator) From
        {
            {5, AddressOf PopulateFourWay},
            {4, AddressOf PopulateFourWay},
            {3, AddressOf PopulateThreeWay},
            {2, AddressOf PopulateTwoWay},
            {1, AddressOf PopulateOneWay}
        }

    Private Sub PopulateOneWay(location As ILocation)
        Utility.Repeat(RNG.RollDice("1d4"), Sub() location.CreateSpawner(CharacterSubtypes.SLIME))
    End Sub

    Private Sub PopulateTwoWay(location As ILocation)
        Utility.Repeat(RNG.RollDice("1d3"), Sub() location.CreateSpawner(CharacterSubtypes.SLIME))
    End Sub

    Private Sub PopulateThreeWay(location As ILocation)
        Utility.Repeat(RNG.RollDice("1d2"), Sub() location.CreateSpawner(CharacterSubtypes.SLIME))
    End Sub

    Private Sub PopulateFourWay(location As ILocation)
        Utility.Repeat(RNG.RollDice("1d1"), Sub() location.CreateSpawner(CharacterSubtypes.SLIME))
    End Sub

    Private Sub PopulateMaze(mazeLocations As IEnumerable(Of ILocation))
        Dim groups = mazeLocations.GroupBy(Function(x) x.Features.Count(Function(y) y.EntitySubtype = FeatureSubtypes.DOOR))
        For Each group In groups
            Dim populator As MazeAreaPopulator = Nothing
            If mazeAreaPopulators.TryGetValue(group.Key, populator) Then
                For Each location In group
                    populator.Invoke(location)
                Next
            End If
        Next
    End Sub
#End Region

    <Extension>
    Private Function InitializeN00b(context As IInitializationContext, checkpoint As IFeature) As CharacterInitializer
        Const MAXIMUM_HEALTH = 100
        Const MAXIMUM_STAMINA = 10
        Const INITIAL_ATTACK = 20
        Const INITIAL_DEFEND = 5
        Return Sub(character)
                   character.SetCheckpoint(checkpoint)
                   character.InitializeCounter(Counters.HEALTH, MAXIMUM_HEALTH, 0, MAXIMUM_HEALTH)
                   character.InitializeCounter(Counters.STAMINA, MAXIMUM_STAMINA, 0, MAXIMUM_STAMINA)
                   character.InitializeCounter(Counters.ATTACK, INITIAL_ATTACK, 0, Integer.MaxValue)
                   character.InitializeCounter(Counters.DEFEND, INITIAL_DEFEND, 0, Integer.MaxValue)
#If DEBUG Then
                   character.InitializeCounter(Counters.CRUOR, 100, 0, Integer.MaxValue)
#Else
                   character.InitializeCounter(Counters.CRUOR, 0, 0, Integer.MaxValue)
#End If
                   character.InitializeCounter(
                        Counters.CLUMSINESS,
                        Enumerable.Range(0, 6).
                            Select(Function(x) RNG.RollDice("1d6")).
                            OrderByDescending(Function(x) x).
                            Take(3).
                            Sum(),
                        0,
                        20)
                   character.World.Avatar = character
               End Sub
    End Function
End Module
