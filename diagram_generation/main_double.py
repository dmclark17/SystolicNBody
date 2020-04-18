from plotter import DoublePlotter
from systolic import DoubleModel

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
model = DoubleModel(32, 4)
plotter = DoublePlotter(4, color_dict)

# Warms up the systolic array so the gif will loop smooothly
for _ in range(10):
    model.forward()

# Adds the state of the systolic array to the plotter then advances the array
for i in range(19):
    plotter.add_frame(model.generate_force_matrix_data(),
                      model.systolic_one.systolic_array,
                      model.systolic_two.systolic_array,
                      model.accumulator.fractions)
    plotter.end_frame()

    model.forward()

plotter.make_animation("figures/double_systolic.gif", 250)
