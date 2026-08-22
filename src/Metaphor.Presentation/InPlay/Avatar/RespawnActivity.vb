Imports Metaphor.Processing
Imports TGGD.Presentation

Friend Module RespawnActivity
    Friend Function Launch(context As IDisplayContext, model As IWorldModel, previous As DialogSource) As DialogSource
        Return Function()
                   model.Avatar.Respawn()
                   Return InPlay.Launch(context, model, previous).Invoke()
               End Function
    End Function
End Module
