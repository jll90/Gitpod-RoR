//= require chartkick
//= require Chart.bundle

function toggleMatchState(event) {
  window.location.href = '/admin/matches?state=' + event.currentTarget.value;
}

function toggleStateProduct(event, state, id) {
  event.preventDefault();
  let humanState = state == 'disable' ? 'Desactivación' : 'Reactivación';
  let question = '¿Confirmar ' + humanState.toLowerCase() + ' del producto?';

  if (confirm(question)) {
    fetch(id + '/toggle_state/' + state, {
      method: 'PUT',
    }).then((response) => {
      if (response.status == 200) {
        alert(humanState + ' exitosa');
        window.location.reload();
      } else {
        alert(humanState + ' fallida');
      }
    });
  }
}

function deleteImageProduct(event, id, image_id) {
  event.preventDefault();
  let question = '¿Confirmar la eliminación de imagen';

  if (confirm(question)) {
    fetch(id + '/remove_image/' + image_id, {
      method: 'DELETE',
    }).then((response) => {
      if (response.status == 200) {
        alert('Imagen eliminada');
        window.location.reload();
      } else {
        alert('Error eliminando imagen');
      }
    });
  }
}
