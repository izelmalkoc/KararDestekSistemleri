// Set new default font family and font color to mimic Bootstrap's default styling
Chart.defaults.global.defaultFontFamily = 'Nunito', '-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';
Chart.defaults.global.defaultFontColor = '#858796';

function getRandomColor() {
    var letters = '0123456789ABCDEF';
    var color = '#';
    for (var i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

// Function to create Pie Chart dynamically
function createDynamicPieChart(data) {
    var ctx = document.getElementById("myPieChartProduct");
    var backgroundColors = ['#4e73df', '#1cc88a', '#36b9cc'];
    var hoverBackgroundColors = ['#2e59d9', '#17a673', '#2c9faf'];

    var satisAnaliziData = data.satisAnalizi;

    var myPieChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: satisAnaliziData.map(category => category.kitap_adi),
            datasets: [{
                data: satisAnaliziData.map(category => category.toplam_satis_adet),
                backgroundColor: satisAnaliziData.map(() => getRandomColor()), // Rastgele renk belirlenmesi
                hoverBackgroundColor: satisAnaliziData.map(() => getRandomColor()), // Rastgele hover renk belirlenmesi
                hoverBorderColor: "rgba(234, 236, 244, 1)",
            }],
        },
        options: {
            maintainAspectRatio: false,
            tooltips: {
                backgroundColor: "rgb(255,255,255)",
                bodyFontColor: "#858796",
                borderColor: '#dddfeb',
                borderWidth: 1,
                xPadding: 15,
                yPadding: 15,
                displayColors: false,
                caretPadding: 10,
            },
            legend: {
                display: false
            },
            cutoutPercentage: 80,
        },
    });
}

// Fetch data from the server
fetch('/admin/fetch-analyzes')
    .then(response => response.json())
    .then(data => {
        // Create the Pie Chart dynamically with fetched data
        createDynamicPieChart(data);
    })
    .catch(error => console.error('Error fetching data:', error));
