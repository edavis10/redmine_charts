function charts_earlier() {
    $('range_offset').value = parseInt($('range_offset').value) + 1;
    $('range_offset').form.submit();
}

function charts_later() {
    $('range_offset').value = parseInt($('range_offset').value) - 1;
    if($('range_offset').value < 1) {
        $('range_offset').value = 1;
    }
    $('range_offset').form.submit();
}