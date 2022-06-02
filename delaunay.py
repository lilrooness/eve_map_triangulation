print("importing packages ...")

from scipy.spatial import Delaunay
import matplotlib.pyplot as plt
import numpy

print("triangulating points")

points = numpy.array([[0,0], [0, 12], [41, 14], [5, 5], [40, 0], [30, 5]])
triangles = Delaunay(points)

print("Plotting triangulated graph")

for t in triangles.simplices:
	x1 = points[t[0]][0]
	y1 = points[t[0]][1]

	x2 = points[t[1]][0]
	y2 = points[t[1]][1]

	x3 = points[t[2]][0]
	y3 = points[t[2]][1]

	print([(x1, y1), (x2, y2), (x3, y3)])

plt.triplot(points[:,0], points[:,1], triangles.simplices)
plt.plot(points[:, 0], points[:,1], 'o')
plt.show()
