const form = document.querySelector("#my_form");
const book_upload = document.querySelector("#book_upload");
const results = document.querySelector("#results");

form.addEventListener("submit", e => {
  /* preventDefault, so that the page doesn't refresh */
  e.preventDefault();
  /* you can fill the formData object automatically with all the data from the form */
  const formData = new FormData(form);
  /* or you can can instantiate an empty FormData object and then fill it using append(). The three arguments to append are the key (equivalent to the name field on an input), the file itself, and an optional third argument for the filename. */
  const formData2 = new FormData();
  formData2.append(
    "csv_file",
    book_upload.files[0],
    book_upload.files[0].name
  );
  /* You can iterate through the FormData object to view its data (this is equivalent to using the .entries() method.) */
  for (const item of formData2) {
    results.innerHTML = `
      <p><strong>name:</strong> ${item[0]}</p>
      <p><strong>filename:</strong> ${item[1].name}</p>
      <p><strong>size:</strong> ${item[1].size}</p>
      <p><strong>type:</strong> ${item[1].type}</p>
    `;
  }
  /* once you've confirmed that the FormData object has all the proper data, send a fetch request. This particular request will go nowhere since I never defined the API_ROOT variable */
  fetch('https://mathsdeptlibrary.herokuapp.com/api/v1/books/batch_create', {
    method: "POST",
    body: formData,
    headers: new Headers({
      'Authorization': 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozMSwiZXhwIjoxNTYyNzU2NTQ1fQ.waYlp3KJpBY51FFbjHY0h3RiHMorV2g_P3p_3RnJA7U',
    }),
  });
});