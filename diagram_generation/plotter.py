import matplotlib
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import matplotlib.patches as patches
import matplotlib.animation as animation
from matplotlib import cm
import numpy as np


class SystolicPlotter():
    def __init__(self, color_dict):
        """
        Constructs a systolic plotter object with given height of the image and
        color_dict. Currently this only works for N=4, n=32 systems
        """
        self.color_dict = color_dict

        self.frame_lists = []
        self.current_frame = []

    def end_frame(self):
        """
        Ends the current frame and saves it to the list of frames to animate
        """
        self.frame_lists.append(self.current_frame)
        self.current_frame = list()

    def make_animation(self, name, speed):
        """
        Creates the animation with given name
        """
        ani = animation.ArtistAnimation(self.fig, self.frame_lists,
                                        interval=speed, blit=True,
                                        repeat_delay=speed)
        ani.save(name, writer='imagemagick')


class SinglePlotter(SystolicPlotter):
    def __init__(self, height, color_dict):
        super().__init__(color_dict)

        self.fig = plt.figure(figsize=(height*3,height))
        self.gs = gridspec.GridSpec(1, 3, figure=self.fig)

        self.force_matrix = ForceMatrixSubplot(self.fig, self.gs[0], color_dict)
        self.systolic = SystolicSubplot(self.fig, self.gs[1], color_dict)
        self.accumulator = AccumulatorSubplot(self.fig, self.gs[2], color_dict)

    def add_frame(self, force_data, systolic_data, accumulator_data):
        self.force_matrix.add(force_data, self.current_frame)
        self.systolic.add(systolic_data, self.current_frame)
        self.accumulator.add(accumulator_data, self.current_frame)


class DoublePlotter(SystolicPlotter):
    def __init__(self, height, color_dict):
        super().__init__(color_dict)

        self.fig = plt.figure(figsize=(height*2,height*2))
        self.gs = gridspec.GridSpec(2, 2, figure=self.fig)

        self.force_matrix = ForceMatrixSubplot(self.fig, self.gs[0,0], color_dict)
        self.accumulator = AccumulatorSubplot(self.fig, self.gs[0,1], color_dict)
        self.systolic_one = SystolicSubplot(self.fig, self.gs[1,0], color_dict,
                                            "Systolic Array One")
        self.systolic_two = SystolicSubplot(self.fig, self.gs[1,1], color_dict,
                                            "Systolic Array Two", 'r')

    def add_frame(self, force_data, systolic_data_one, systolic_data_two,
                  accumulator_data):
        self.force_matrix.add(force_data, self.current_frame)
        self.systolic_one.add(systolic_data_one, self.current_frame)
        self.systolic_two.add(systolic_data_two, self.current_frame)
        self.accumulator.add(accumulator_data, self.current_frame)


class AccumulatorSubplot():
    def __init__(self, fig, gs_ele, color_dict):
        self.accumulators_axis = [list([None] * 8) for _ in range(4)]
        self.color_dict = color_dict

        ax = fig.add_subplot(gs_ele)
        ax.axis('off')
        ax.set_title("Accumulators")

        accumulators_grid = gs_ele.subgridspec(4, 8)
        for i in range(4):
            for j in range(8):
                ax = fig.add_subplot(accumulators_grid[i,j])
                ax.grid('on')

                ax.set_xlim(0,1)
                ax.set_ylim(0,1)
                major_ticks = np.arange(0, 1, 0.25)
                ax.set_yticks(major_ticks)
                ax.set_xticks([])

                ax.set_xticklabels([])
                ax.set_yticklabels([])

                self.accumulators_axis[i][j] = ax

    def add(self, data, current_frame):
        """
        Adds the accumulators to the current frame

        Data should be a one dimensional array of length 32 with value from 0
        to 1 corresponding to the fraction completed
        """
        for j in range(8):
            for i in range(4):
                ax = self.accumulators_axis[i][j]

                rect = patches.Rectangle((0,0), 1, data[i+j*4], fill=True,
                                         color=self.color_dict[j])
                r_patch = ax.add_patch(rect)
                current_frame.append(r_patch)


class ForceMatrixSubplot():
    def __init__(self, fig, gs_ele, color_dict):
        self.force_matrix_axis = [list([None] * 8) for _ in range(8)]
        self.color_dict = color_dict

        ax = fig.add_subplot(gs_ele)
        ax.axis('off')
        ax.set_title("Force Matrix")

        force_matrix_grid = gs_ele.subgridspec(9, 9)

        for i in range(8):
            ax = fig.add_subplot(force_matrix_grid[0,i])
            ax.axis('off')
            rect = patches.Rectangle((0,0), 1, 0.2, fill=True,
                                     color=self.color_dict[i])
            ax.add_patch(rect)

        for j in range(8):
            ax = fig.add_subplot(force_matrix_grid[j+1,8])
            ax.axis('off')
            rect = patches.Rectangle((0,0), 0.2, 1, fill=True,
                                     color=self.color_dict[j])
            ax.add_patch(rect)

        for i in range(8):
            for j in range(i, 8):
                ax = fig.add_subplot(force_matrix_grid[i+1,j])
                ax.get_xaxis().set_visible(False)
                ax.get_yaxis().set_visible(False)
                for axis in ['top','bottom','left','right']:
                    ax.spines[axis].set_linewidth(0.1)

                self.force_matrix_axis[i][j] = ax

    def add(self, data, current_frame):
        """
        Adds a force matrix to the current frame.

        Data should be a 32 by 32 matrix with 1s at the locations where elements
        are currently being calculated
        """
        for i in range(8):
            for j in range(i, 8):
                ax = self.force_matrix_axis[i][j]
                local_data = data[i*4:(i+1)*4, j*4:(j+1)*4]

                im = ax.imshow(local_data,cmap=cm.binary)
                current_frame.append(im)

                if np.any(local_data==1):
                    l, r, b, t, = im.get_extent()
                    rect = patches.Rectangle((l,b), r-l, t-b, fill=False,
                                             clip_on=False)
                    r_patch = ax.add_patch(rect)
                    current_frame.append(r_patch)

                if np.any(local_data==2):
                    l, r, b, t, = im.get_extent()
                    rect = patches.Rectangle((l,b), r-l, t-b, fill=False,
                                             clip_on=False, color='r')
                    r_patch = ax.add_patch(rect)
                    current_frame.append(r_patch)


class SystolicSubplot():
    def __init__(self, fig, gs_ele, color_dict, title=None, arrow_color=None):
        if not title:
            title = "Systolic Array"

        if not arrow_color:
            arrow_color = 'k'

        self.systolic_arr_axis = [list([None] * 4) for _ in range(4)]
        self.color_dict = color_dict

        ax = fig.add_subplot(gs_ele)
        ax.axis('off')
        ax.set_title(title, fontdict={"color":arrow_color})

        accumulators_grid = gs_ele.subgridspec(4, 4)

        for i in range(4):
            for j in range(4):
                ax = fig.add_subplot(accumulators_grid[i,j])
                ax.axis('off')

                rect = patches.Rectangle((0.1,0.1), 0.8, 0.8, fill=False,
                                         zorder=1.5, linewidth=3)
                ax.add_patch(rect)

                line = patches.Polygon(np.array([[0.1,0.9],[0.9,0.1]]),
                                       closed=False, color='k', fill=False,
                                       linewidth=3, zorder=1.5)
                ax.add_patch(line)

                if j != 3:
                    arrow = patches.Arrow(0.9,0.5,0.35,0, width=0.2,
                                          color=arrow_color, clip_on=False)
                    ax.add_patch(arrow)

                if i != 3:
                    arrow = patches.Arrow(0.5,0.1,0,-0.35, width=0.2,
                                          color=arrow_color, clip_on=False)
                    ax.add_patch(arrow)

                self.systolic_arr_axis[i][j] = ax

    def add(self, data, current_frame):
        """
        Adds the systolic array to the current frame

        data should be a 4 by 4 matrix of tuples (i, j) where i,j are in [0,32]
        """
        for i in range(4):
            for j in range(4):
                ax = self.systolic_arr_axis[i][j]

                top = patches.Polygon(np.array([[0.1,0.9],[0.9,0.1],[0.9,0.9]]),
                                      color=self.color_dict[data[i,j,0]//4],
                                      fill=True, linewidth=0, zorder=1.0)
                ax.add_patch(top)
                current_frame.append(top)

                right = patches.Polygon(np.array([[0.1,0.9],[0.9,0.1],[0.1,0.1]]),
                                        color=self.color_dict[data[i,j,1]//4],
                                        fill=True, linewidth=0, zorder=1.0)
                ax.add_patch(right)
                current_frame.append(right)
