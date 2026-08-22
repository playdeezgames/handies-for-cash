Imports Metaphor.Extensions
Imports Metaphor.Persistence

Friend Class FeaturesModel
    Implements IFeaturesModel

    Private ReadOnly world As IWorld

    Private Sub New(world As IWorld)
        Me.world = world
    End Sub

    Public ReadOnly Property HasAny As Boolean Implements IFeaturesModel.HasAny
        Get
            Return world.Avatar.Location.Features.Any(Function(x) Not x.IsHidden)
        End Get
    End Property

    Public ReadOnly Property AllVisible As IEnumerable(Of IFeatureModel) Implements IFeaturesModel.AllVisible
        Get
            Return world.Avatar.Location.Features.Where(Function(x) Not x.IsHidden).Select(AddressOf FeatureModel.Create)
        End Get
    End Property

    Public Sub ShowList() Implements IFeaturesModel.ShowList
        world.ClearMessages()
    End Sub

    Friend Shared Function Create(entity As IWorld) As IFeaturesModel
        Return New FeaturesModel(entity)
    End Function
End Class
