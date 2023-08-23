import { createChart } from "lightweight-charts";

const StockChart = {
  chart: null,
  mounted() {
    this.chart = createChart("chart", {
      width: window.innerWidth * 0.5,
      height: window.innerHeight * 0.5,
      rightPriceScale: {
        visible: true,
      },
      // leftPriceScale: {
      //   visible: true,
      // },
    });
    const seriesBTC = this.chart.addLineSeries({ priceScaleId: "right" });

    seriesBTC.priceScale().applyOptions({
      autoScale: true,
      borderColor: "#71649C",
      scaleMargins: {
        top: 0.7, // highest point of the series will be 70% away from the top
        bottom: 0.2,
      },
      minValue: 0,
      tickSize: 10,
      minTick: 0.1,
      precision: 2,
    });

    this.chart.timeScale().applyOptions({
      borderColor: "#71649C",
      tickMarkTime: 4,
      secondsVisible: true,
    });
    this.chart.timeScale().fitContent();

    this.handleEvent("price_update", (msg) => {
      const [time, curr] = Object.keys(msg);
      const newPriceEvt = {
        time: Date.parse(msg.time) / 1000,
        value: msg[curr],
      };
      seriesBTC.update(newPriceEvt);
    });
    window.addEventListener("resize", () => {
      this.chart.resize(window.innerWidth * 0.4, window.innerHeight * 0.4);
    });
  },

  destroyed() {
    this.chart.remove();
  },
};

export default StockChart;
