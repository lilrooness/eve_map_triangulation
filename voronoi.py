print("importing scipy packages ...")

from scipy.spatial import Voronoi, voronoi_plot_2d
import matplotlib.pyplot as plt
import numpy
from region import lonetrek

print("reading points ...")

p = []
systems = []

name = ""

with open("normalisedmap") as mapfile:

    name = mapfile.readline()
    for line in mapfile:
        parts = line.split(" ")
        systemName = parts[0]
        x = float(parts[1])
        y = float(parts[2])
        z = float(parts[3])
        p.append([y, z])
        systems.append(systemName)


min = -100
max = 1100

# wrap system points in a bounding box of points
# Box Top
for x in range(min, max, 2):
    p.append([x, max])
    systems.append("BOUNDING_POINT")
# Box Bottom
for x in range(min, max, 2):
    p.append([x, min])
    systems.append("BOUNDING_POINT")
# Box Left
for y in range(min, max, 2):
    p.append([min, y])
    systems.append("BOUNDING_POINT")
# Box Right
for y in range(min, max, 2):
    p.append([max, y])
    systems.append("BOUNDING_POINT")

points = numpy.array(p)

print("Calculating Voronoi Diagram ...")
vor = Voronoi(points)

# TODO output some polygon data here that is labeled with star/constellation/region data

# print(vor.point_region)

with open("output_data/points", 'w') as outfile:
    for i in range(len(vor.points)):
        systemName = systems[i]
        point = points[i]
        line = ",".join([str(x) for x in point])
        outfile.write(line)
        outfile.write("\n")

with open("output_data/vertices", 'w') as outfile:
    for v in vor.vertices:
        line = ",".join([str(x) for x in v])
        outfile.write(line)
        outfile.write("\n")

with open("output_data/indices", 'w') as outfile:
    for i in range(len(points)):
        systemName = systems[i]
        indicies_idx = vor.point_region[i]
        indices = vor.regions[indicies_idx]
        outfile.write(systemName + " ")
        line = ",".join([str(x) for x in indices])
        outfile.write(line)
        outfile.write("\n")


print("Plotting Points to Figure ...")
fig = voronoi_plot_2d(vor, show_vertices=False, show_points=True)

print("Showing Plot ...")
plt.title(name)
plt.show()

print("Exiting")
