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

points = numpy.array(p)

print("Calculating Voronoi Diagram ...")
vor = Voronoi(points)

# TODO output some polygon data here that is labeled with star/constellation/region data

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
        indices = vor.regions[i]
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
