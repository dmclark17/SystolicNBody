from plotter import SinglePlotter
from systolic import SingleModel

color_dict = {
    -1:'w',
    0:'#336699',
    1:'#9EE493',
    2:'#E3170A',
    3:'#DAF7DC',
    4:'#8A716A',
    5:'#86BBD8',
    6:'#E7E247',
    7:'#474A2C'
}

# Creates the model and plotter
model = SingleModel(32, 4)
plotter = SinglePlotter(4, color_dict)

# Warms up the systolic array so the gif will loop smooothly
for _ in range(9):
    model.forward()

# Adds the state of the systolic array to the plotter then advances the array
for _ in range(36):
    plotter.add_frame(model.generate_force_matrix_data(),
                      model.systolic_array.systolic_array,
                      model.accumulator.fractions)
    plotter.end_frame()

    model.forward()

plotter.make_animation("figures/single_systolic.gif", 250)
