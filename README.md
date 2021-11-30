# Simple Geometry Shader Case

 <img src="mdAsset\Geometry.gif" alt="Geometry" style="zoom: 80%;" />







# Some deliberation in the implement.

​	The geometry pragma can generate a triangular surface when I call the method ***Restart Strip*** after I put three vertexes in to the stream.  But if I put four vertexes into the stream by sequence. It can generate a rectangle. 

​	I thought can I put a sequence of vertexes to form a cube ? what the sequence is?

​	The rule of generation is, Imaged a sliding window that step is one. The relationship is *vertexes count - 2 = surfaces number*. So there are 14 vertexes in the collection if I wanna form a cube. 

​	

​	<img src="mdAsset\Define.png" alt="Define">

​	

End on E will turn the direction.
End on S edge will form a rectangle and keep the direction.

<img src="mdAsset\Case.png" alt="Case">

Finally, I just find one solution instead of a real result. I thought it maybe will use some knowledge of topology or group theory. I can't solve right now. perhaps that kind of question must be solved by others. 