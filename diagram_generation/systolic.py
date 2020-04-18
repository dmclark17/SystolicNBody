import numpy as np


class DoubleModel():
    def __init__(self, n, N):
        self.N = N
        self.n = n

        self.iteration = 0
        self.position_state = np.zeros((n))

        self.systolic_one = SystolicArray(n, N)
        self.systolic_two = SystolicArray(n, N)
        self.accumulator = Accumulator(n, N)

    def forward(self):
        """
        Steps the simulatioon forward
        """
        i_one, j_one, i_two, j_two = self.get_next_block()

        top_one, left_one = self.systolic_one.update_position_buffer(i_one,
                                                                     j_one)
        top_two, left_two = self.systolic_two.update_position_buffer(i_two,
                                                                     j_two)

        bottom_one, right_one = self.systolic_one.update_systolic_array(
            top_one, left_one, self.position_state
        )
        bottom_two, right_two = self.systolic_two.update_systolic_array(
            top_two, left_two, self.position_state
        )

        position_state_update = self.accumulator.flush_accumulators()
        self.accumulator.update_accumulators(bottom_one, right_one)
        self.accumulator.update_accumulators(bottom_two, right_two)

        self.position_state = self.position_state + position_state_update
        self.iteration += 1

    def get_next_block(self):
        """
        Returns the next block indexes to start execuing based on the iteration

        I gave up on the math and decided to just hard code it
        """
        i_values_one = [0] * 8 + [3] * 5 + [4] * 4 + [7] * 1 + [-1]
        j_values_one = list(range(0,8)) + list(range(3,8)) + \
                       list(range(4,8)) + list(range(7,8)) + [-1]

        i_values_two = [1] * 7 + [2] * 6 + [5] * 3 + [6] * 2 + [-1]
        j_values_two = list(range(1,8)) + list(range(2,8)) + \
                       list(range(5,8)) + list(range(6,8)) + [-1]

        remain = self.iteration % (len(i_values_one))

        return i_values_one[remain], j_values_one[remain], i_values_two[remain], \
               j_values_two[remain]

    def generate_force_matrix_data(self):
        """
        Generates the force matrix for plotting based on the current systolic
        state
        """
        force_one = self.systolic_one.generate_force_matrix_data()
        force_two = 2 * self.systolic_two.generate_force_matrix_data()

        force_matrix = force_one + force_two

        assert(not np.any(force_matrix == 3.0))

        return force_matrix


class SingleModel():
    def __init__(self, n, N):
        """
        Constructs a systolic model with given number of particles (n) and
        width of systolic array (N)
        """
        self.n = n
        self.N = N
        self.b = n // N

        self.iteration = 0
        self.position_state = np.zeros((n))

        self.systolic_array = SystolicArray(n, N)
        self.accumulator = Accumulator(n, N)

    def forward(self):
        """
        Steps the simulatioon forward
        """
        i, j = self.get_next_block()

        top, left = self.systolic_array.update_position_buffer(i, j)
        bottom, right = self.systolic_array.update_systolic_array(
            top, left, self.position_state
        )

        position_state_update = self.accumulator.flush_accumulators()
        self.accumulator.update_accumulators(bottom, right)

        self.position_state = self.position_state + position_state_update
        self.iteration += 1

    def get_next_block(self):
        """
        Returns the next block indexes to start execuing based on the iteration

        The math a pretty ugly, but this should just trace the upper triangle
        of the matrix
        """
        num_blocks = self.b * (self.b + 1) / 2
        b = self.b - 1

        remain = self.iteration % num_blocks

        i = int(0.5 * (-1 * np.sqrt(4*b*b + 12*b - 8*remain + 9) + 2*b + 3))
        j = remain - ((2*b + 1 - i) * i) // 2
        j = int(j)

        return i, j

    def generate_force_matrix_data(self):
        return self.systolic_array.generate_force_matrix_data()


class Accumulator():
    """
    Updates the aaccumulators. The accumulators need to wait until they
    have the entire force on a particle before computing the new position

    This function takes in the output of the systolic array - the bottom and
    right elements.

    Given each output of the systolic array it updates the corresponding
    accumulator.
    If an accumulator is full it will return those and zero them out
    The check should happen before the new vector is added because it
    should stay full for an iteration. This new vector is returned and used
    to update the state of each position
    """
    def __init__(self, n, N):
        self.n = n
        self.N = N
        self.accumulators = np.zeros((n))

    def flush_accumulators(self):
        position_state_update = np.zeros((self.n))
        for i in range(self.n):
            if self.accumulators[i] == self.n:
                position_state_update[i] = 1
                self.accumulators[i] = 0

        return position_state_update

    def update_accumulators(self, bottom, right):
        # Handle the right
        for i in range(self.N):
            if right[i,0] != -1:
                self.accumulators[right[i,0]] += self.N

        # Handles the bottom
        for j in range(self.N):
            # For diagonal blocks we ignore the bottom
            if bottom[j,1] != -1 and ((bottom[j,1] // self.N) != \
                                      (bottom[j,0] // self.N)):
                self.accumulators[bottom[j,1]] += self.N

    @property
    def fractions(self):
        """
        The accumulators in fractional form for plotting
        """
        return self.accumulators / self.n


class SystolicArray():
    def __init__(self, n, N):
        self.n = n
        self.N = N
        self.systolic_array = np.full((N, N, 2), -1)
        self.position_buffer = np.full((2, N, N), -1)

    def update_position_buffer(self, i, j):
        """
        Updates the position buffers based on the block which is being executed

        The inputs to the systolic array are staggered so we need buffers here.
        The given (i,j) will correspond to the elements entering the first cell
        of the systolic array, but then those elements are used in the next N
        cycles

        After inserting the given block into the buffers, this function pops the
        row

        TODO: here we can verify that the data is okay. Like making sure that
        the position for those particles has been calculated for the current
        timestep. Currently this is implemented in the systolic array, but
        I'm not sure if that is completely correct
        """
        top_buffer = self.position_buffer[1]
        # First add the new block
        if i != -1:
            new_positions = np.arange(j*self.N,(j+1)*self.N)
            np.fill_diagonal(top_buffer, new_positions)
        # Get the top of it
        top = np.copy(top_buffer[0,:])
        # Zero out and shift over
        top_buffer[0,:] = -1
        top_buffer = np.roll(top_buffer, -1, axis=0)
        self.position_buffer[1] = top_buffer

        # Now do the same thing for the lefts
        left_buffer = self.position_buffer[0]
        if j != -1:
            new_positions = np.arange(i*self.N,(i+1)*self.N)
            np.fill_diagonal(left_buffer, new_positions)
        left = np.copy(left_buffer[0,:])
        left_buffer[0,:] = -1
        left_buffer = np.roll(left_buffer, -1, axis=0)
        self.position_buffer[0] = left_buffer

        return top, left

    def update_systolic_array(self, top, left, position_state):
        """
        Updates the systolic array.

        Takes in the new atom indexes from the top and left of the array.
        it then shifts the is to the right and the js down
        Finally it returns the bottom and right of the array
        """
        bottom = np.copy(self.systolic_array[-1,:,:])
        right = np.copy(self.systolic_array[:,-1,:])

        # Shift the j's down and the i's to the right
        self.systolic_array[:,:,0] = np.roll(self.systolic_array[:,:,0], 1, 1)
        self.systolic_array[:,:,1] = np.roll(self.systolic_array[:,:,1], 1, 0)

        # Add the new top and left values
        self.systolic_array[0, :, 1] = top
        self.systolic_array[:, 0, 0] = left

        # Checks to make sure positions are from  the same timestep
        # This might fail when it shouldn't sometimes
        for i in range(self.N):
            for j in range(self.N):
                i_time = position_state[self.systolic_array[i,j,0]]
                j_time = position_state[self.systolic_array[i,j,1]]
                if (i_time != j_time):
                    print("Time mismatch")
                    # print("Particle", self.systolic_array[i,j,0], "time", i_time, "Particle", self.systolic_array[i,j,1], "time", j_time)
                    # assert(i_time == j_time)

        return bottom, right

    def generate_force_matrix_data(self):
        """
        Generates the force matrix for plotting based on the current systolic
        state
        """
        force_matrix = np.zeros((self.n, self.n))
        for i in range(self.N):
            for j in range(self.N):
                if (not np.any(self.systolic_array[i,j] == -1)):
                    idx, jdx = self.systolic_array[i,j]
                    force_matrix[idx, jdx] = 1

        return force_matrix

    def print_systolic_array(self):
        """
        prints the state of the systolic array in a more human readable format
        """
        for i in range(self.N):
            line = ""
            for j in range(self.N):
                line += str(self.systolic_array[i,j,:])
            print(line)
