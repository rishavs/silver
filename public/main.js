const toggle_more_tag_controls = () => {
    if (get_cookie('usertoken') || get_cookie('usertoken') != 'none') {
        document.getElementById('more_tag_controls').style.display = 'block';
    }
}

const fetch_all_tags = async () => {
    all_tags_list = await make_rest_post_request({}, `/t/all`)
    // console.log(all_tags_list)
}



const toggle_post_reply = () => {
    // ensure user is logged in to use this action
    // utils.redirect_to_login_if_not_loggedin()

    var component = document.getElementById('reply_form')
    if (component.style.display === 'none') {
        component.style.display = 'block';

        // this bit is mainly for a smoother transition
        document.getElementById('textarea_reply_form').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
        document.getElementById('textarea_reply_form').focus();

    } else {
        component.style.display = 'none';
    }
}

const toggle_comment_reply = (id) => {
    // ensure user is logged in to use this action
    // utils.redirect_to_login_if_not_loggedin()

    var component = document.getElementById('comment_for_id:' + id)
    if (component.style.display === 'none') {
        component.style.display = 'block';

        // this bit is mainly for a smoother transition. Broken in chrome
        document.getElementById('textarea_for_id:' + id).scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
        document.getElementById('textarea_for_id:' + id).focus();
    } else {
        component.style.display = 'none';
    }
}
// This script simply toggles the input field between password and text types.
// This allows users to check the password they are writing without having to retype it.
const toggle_password = () => {
    var p = document.getElementById('password');
    var tp = document.getElementById('toggle_password');
    if (p.type === 'password') {
        p.type = 'text';
        tp.classList.remove('circular', 'eye', 'slash', 'outline', 'link', 'icon')
        tp.classList.add('circular', 'eye', 'link', 'icon')

    } else {
        p.type = 'password';
        tp.classList.remove('circular', 'eye', 'link', 'icon')
        tp.classList.add('circular', 'eye', 'slash', 'outline', 'link', 'icon')
    }
}
// This script resets the inut to password type before submit.
// This esnues that the browser is able to save the password as it is a recognised input type.
const reset_password_input = () => {
    var p = document.getElementById('password');
    if (p.type === 'text') {
        p.type = 'password'
    }
}

const like_post = async (id) => {
    redirect_to_login_if_not_loggedin()
    const component = document.getElementById(`like_btn_for_post:${id}`)
    const count = document.getElementById(`like_btn_count_for_post:${id}`)

    if (component.getAttribute('data-state') === 'default') {
        component.classList.remove('basic')
        component.classList.add('red')
        component.setAttribute('data-state', 'liked')
        count.textContent++

        await make_rest_post_request({}, `/p/${id}/like`)
    } else {
        component.classList.remove('red')
        component.classList.add('basic')
        component.setAttribute('data-state', 'default')
        count.textContent--

        await make_rest_post_request({}, `/p/${id}/unlike`)
    }

}

const upvote_tag_for_post = async (tagname, postid) => {
    redirect_to_login_if_not_loggedin()
    const tagscore_component = document.getElementById(`tag_score_for_tagname:${tagname}`)
    const tagup_component = document.getElementById(`tag_up_btn_for_tagname:${tagname}`)
    const tagdown_component = document.getElementById(`tag_down_btn_for_tagname:${tagname}`)

    if (tagup_component.getAttribute('data-state') === 'default') {
        tagup_component.classList.add('red')
        tagup_component.setAttribute('data-state', 'active')
        tagdown_component.classList.remove('red')
        tagdown_component.setAttribute('data-state', 'default')
        tagscore_component.textContent++

        await make_rest_post_request({}, `/p/${postid}/upvote/${tagname}`)
    } else {
        tagup_component.classList.remove('red')
        tagup_component.setAttribute('data-state', 'default')
        tagscore_component.textContent--

        await make_rest_post_request({}, `/p/${postid}/upvote/${tagname}`)
    }

}
const downvote_tag_for_post = async (tagname, postid) => {
    redirect_to_login_if_not_loggedin()
    const tagscore_component = document.getElementById(`tag_score_for_tagname:${tagname}`)
    const tagup_component = document.getElementById(`tag_up_btn_for_tagname:${tagname}`)
    const tagdown_component = document.getElementById(`tag_down_btn_for_tagname:${tagname}`)

    if (tagdown_component.getAttribute('data-state') === 'default') {
        tagdown_component.classList.add('red')
        tagdown_component.setAttribute('data-state', 'active')
        tagup_component.classList.remove('red')
        tagup_component.setAttribute('data-state', 'default')
        tagscore_component.textContent--

        await make_rest_post_request({}, `/p/${postid}/downvote/${tagname}`)
    } else {
        tagdown_component.classList.remove('red')
        tagdown_component.setAttribute('data-state', 'default')
        tagscore_component.textContent++

        await make_rest_post_request({}, `/p/${postid}/downvote/${tagname}`)
    }

}

const make_rest_post_request = async (payload, path) => {
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
    };
    try {
        const response = await fetch(path, options)
        console.log(response)
        const json = await response.json();
        console.log(json)
        return json
    } catch (err) {
        console.log('Error getting documents', err)
    }
}

const redirect_to_login_if_not_loggedin = () => {
    if (!get_cookie('usertoken') || get_cookie('usertoken') === 'none') {
        console.log('401 Detected. Redirecting....')
        window.location = '/login'
    }
}
const get_cookie = (name) => {
    var value = '; ' + document.cookie;
    var parts = value.split('; ' + name + '=');
    if (parts.length == 2) return parts.pop().split(';').shift();
};

const sleep = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms));
}
const timespan = (t) => {
    console.log('t')
}

// $('.ui.dropdown').dropdown();
$('.ui.dropdown').dropdown({
    apiSettings: {
        // this url parses query server side and returns filtered results
        url: '//localhost:3000/t/all',
        method: "POST"
    },
});
$('.ui.accordion').accordion({
    onOpening: fetch_all_tags
});
