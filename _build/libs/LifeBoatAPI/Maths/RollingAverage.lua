
---@section RollingAverage

---A rolling average across a given number of values
---Useful for filtering noisey values
---@class LifeBoatAPI.RollingAverage
---@field maxValues number number of values this rolling average holds
---@field values number[] list of values to be averaged
---@field average number current average of the values that have been added
---@field count number number of values currently being averaged
---@field sum number total of the currently tracked values
LifeBoatAPI.RollingAverage = {

    ---@param cls LifeBoatAPI.RollingAverage
    ---@param maxValues number number of values this rolling average holds
    ---@return LifeBoatAPI.RollingAverage
    new = function (cls, maxValues)
        return {
            values = {},
            maxValues = maxValues or math.maxinteger,
            index = 1,
            addValue = cls.addValue
        }
    end;

    ---Add a value to the rolling average
    ---@param self LifeBoatAPI.RollingAverage
    ---@param value number value to add into the rolling average
    ---@return number average the current rolling average (also accessible via .average)
    addValue = function (self, value)
        self.values[(self.index % self.maxValues) + 1] = value
        self.index = self.index + 1

        self.count = self.index < self.maxValues and self.index or self.maxValues
        self.sum = 0
        for i=1,#self.values do
            self.sum = self.sum + self.values[i]
        end
        self.average = self.sum / self.count
        return self.average
    end;
}
---@endsection
