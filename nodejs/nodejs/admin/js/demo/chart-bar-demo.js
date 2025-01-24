// Set new default font family and font color to mimic Bootstrap's default styling
Chart.defaults.global.defaultFontFamily = 'Nunito', '-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';
Chart.defaults.global.defaultFontColor = '#858796';

function createDynamicBarChart(data) {
// Extract data from the response
const labels = Object.keys(data).map(year => year.toString());
const datasets = Object.values(data).reduce((acc, salesArray) => {
  salesArray.forEach(sale => {
    const existingDataset = acc.find(dataset => dataset.label === sale.kitap_id.toString());
    if (existingDataset) {
      existingDataset.data.push(sale.satis_sayisi);
    } else {
      acc.push({
        label: sale.kitap_adi,
        backgroundColor: getRandomColor(),
        hoverBackgroundColor: getRandomColor(),
        borderColor: getRandomColor(),
        data: [sale.satis_sayisi],
      });
    }
  });
  return acc;
}, []);


  // Bar Chart Example
  var ctx = document.getElementById("myBarChart");
  var myBarChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: datasets,
    },
    options: {
      maintainAspectRatio: false,
      layout: {
        padding: {
          left: 10,
          right: 25,
          top: 25,
          bottom: 0
        }
      },
      scales: {
        xAxes: [{
          gridLines: {
            display: false,
            drawBorder: false
          },
          ticks: {
            maxTicksLimit: 6
          },
          maxBarThickness: 25,
        }],
        yAxes: [{
          ticks: {
            min: 0,
            maxTicksLimit: 5,
            padding: 10,
          },
          gridLines: {
            color: "rgb(234, 236, 244)",
            zeroLineColor: "rgb(234, 236, 244)",
            drawBorder: false,
            borderDash: [2],
            zeroLineBorderDash: [2]
          }
        }],
      },
      legend: {
        display: true,
      },
      tooltips: {
        titleMarginBottom: 10,
        titleFontColor: '#6e707e',
        titleFontSize: 14,
        backgroundColor: "rgb(255,255,255)",
        bodyFontColor: "#858796",
        borderColor: '#dddfeb',
        borderWidth: 1,
        xPadding: 15,
        yPadding: 15,
        displayColors: false,
        caretPadding: 10,
        callbacks: {
          label: function(tooltipItem, chart) {
            var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
            return datasetLabel + ': ' + tooltipItem.yLabel;
          }
        }
      },
    }
  });
}

// Fetch data from the server
fetch('/admin/fetch-products-with-sales-by-store-grouped')
  .then(response => response.json())
  .then(data => {
    createDynamicBarChart(data);
  })
  .catch(error => console.error('Error fetching data:', error));

// Helper function to generate random colors
function getRandomColor() {
  var letters = '0123456789ABCDEF';
  var color = '#';
  for (var i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}
