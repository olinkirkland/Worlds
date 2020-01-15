package layers {
    import flash.geom.Point;

    import graph.Cell;


    public class Wind {
        public var points:Array;
        public var hexes:Array;

        private var grid:Array;


        public function Wind(map:Map) {
            points = [];
            hexes = [];
            grid = [[]];

            var radius:Number = 15;

            var offset:Point = new Point(15, 30);
            var width:int = (map.width) / (Math.sqrt(3) * radius);
            var height:int = (map.height - 30) / (radius * 2 * 0.75);

            for (var i:int = 0; i < width; i++) {
                grid [i] = [];
                for (var j:int = 0; j < height; j++) {
                    var w:Number = Math.sqrt(3) * radius;
                    var x:Number = i * w;
                    x += (w / 2) * (j % 2);
                    var y:Number = j * (2 * radius * 0.75);

                    var p:Point = new Point(offset.x + x,
                            offset.y + y);
                    var hex:WindCell = new WindCell(p,
                            radius);

                    points.push(p);
                    hexes.push(hex);
                    grid[i][j] = hex;
                }
            }

            for (i = 0; i < width; i++) {
                for (j = 0; j < height; j++) {
                    var h:WindCell = grid[i][j];
                    var odd:Boolean = j % 2 == 1;

                    // E
                    x = i + 1;
                    y = j;
                    if (x >= grid.length)
                        x = 0;
                    h.addNeighbor(grid[x][y], 0);

                    // W
                    x = i - 1;
                    y = j;
                    if (x < 0)
                        x = grid.length - 1;
                    h.addNeighbor(grid[x][y], 180);

                    // NE
                    x = odd ? i + 1 : i;
                    y = j - 1;
                    if (x >= grid.length)
                        x = 0;
                    if (y >= 0)
                        h.addNeighbor(grid[x][y], 300);

                    // NW
                    x = odd ? i : i - 1;
                    y = j - 1;
                    if (x < 0)
                        x = grid.length - 1;
                    if (y >= 0)
                        h.addNeighbor(grid[x][y], 240);

                    // SE
                    x = odd ? i + 1 : i;
                    y = j + 1;
                    if (x >= grid.length)
                        x = 0;
                    if (y < grid[x].length)
                        h.addNeighbor(grid[x][y], 60);

                    // SW
                    x = odd ? i : i - 1;
                    y = j + 1;
                    if (x < 0)
                        x = grid.length - 1;
                    if (y < grid[x].length)
                        h.addNeighbor(grid[x][y], 120);
                }
            }

            for each (h in hexes) {
                var averageHeight:Number = 0;
                var quadPoints:Array = map.quadTree.queryFromPoint(h.point, radius);
                var ocean:Boolean = false;
                for each (p in quadPoints) {
                    var cell:Cell = map.getCellByPoint(p);
                    averageHeight += cell.height;
                    if (cell.ocean)
                        ocean = true;
                }

                if (ocean)
                    h.height = map.seaLevel;
                else {
                    averageHeight /= quadPoints.length;
                    h.height = averageHeight >= 0 ? averageHeight : -1;
                }
            }

            // Smoothing for hexes that don't have any points under them
            /*for each (h in hexes) {
                if (h.height < 0) {
                    h.height = 0;
                    i = 0;
                    for each (var n:WindCell in h.neighbors)
                        if (n.height >= 0) {
                            h.height += n.height;
                            i++;
                        }
                    h.height /= i;
                }
            }*/

            for each (h in hexes) {
                h.angle = 90;
                h.strength = 5;
            }
        }

        public function hexFromPoint(p:Point):WindCell {
            for each (var hex:WindCell in hexes) {
                if (hex.point.equals(p)) {
                    return hex;
                }
            }

            return null;
        }
    }
}
