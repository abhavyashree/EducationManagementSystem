function login() {
    let userType = document.getElementById("userType").value;
    let email = document.getElementById("email").value;
    let password = document.getElementById("password").value;

    fetch("http://127.0.0.1:5000/login", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            email: email,
            password: password,
            userType: userType
        })
    })
    .then(res => res.json())
    .then(data => {
        if (data.status === "success") {
            
            localStorage.setItem("user_id", data.user_id);
            localStorage.setItem("userType", data.userType);
            if (userType === "student") {
                window.location.href = "student.html";   // 👈 redirect
            } else {
                window.location.href = "faculty.html";   // 👈 redirect
            }

        } else {
            document.getElementById("message").innerText = "Invalid Login";
        }
    })
    .catch(err => console.log(err));
}

function selectUser(type, btn) {
    document.getElementById("userType").value = type;

    let buttons = document.querySelectorAll(".user-toggle button");
    buttons.forEach(b => b.classList.remove("active"));

    btn.classList.add("active");
}

