Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module FeatureExtensions
    <Extension>
    Public Sub Describe(feature As IFeature)
        feature.AddMessage($"TODO: Describe {feature.Name}.")
    End Sub
End Module
