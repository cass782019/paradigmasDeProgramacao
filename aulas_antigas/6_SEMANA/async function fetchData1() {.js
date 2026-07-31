async function fetchData1() {
    let response = await fetch('https://api.example.com/data1');
    let data = await response.json();
    console.log(data);
}

async function fetchData2() {
    let response = await fetch('https://api.example.com/data2');
    let data = await response.json();
    console.log(data);
}

async function runConcurrently() {
    await Promise.all([fetchData1(), fetchData2()]);
}

runConcurrently();
