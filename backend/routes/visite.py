from flask import request

from sqlalchemy.orm.exc import NoResultFound

from geonature.utils.env import DB
from geonature.utils.utilssqlalchemy import json_resp, GenericQuery

from geonature.core.gn_monitoring.models import TBaseVisits

from ..blueprint import blueprint
from ..models.visite import ConditionsVisite
from ..utils.repos import (
    GNMonitoringVisiteRepository,
    GNMonitoringContactTaxon
)  # TODO déplacement repos dans core


def _format_visite_data(data):
    result = data.as_dict()
    result.update(data.base_visit.as_dict(recursif=False))
    result['observers'] = [
        o.id_role for o in data.base_visit.observers
    ]
    result["id"] = data.base_visit.id_base_visit
    return result


@blueprint.route('/visites/<id_base_site>', methods=['GET'])
@json_resp
def get_all_visites_chiro(id_base_site):
    data = GenericQuery(
        DB.session, 'v_visites_chiro', 'monitoring_chiro', None,
        {"id_base_site": id_base_site}, 1000, 0
    ).return_query()

    data["total"] = data["total_filtered"]
    return data


@blueprint.route('/visite/<id_base_visit>', methods=['GET'])
@json_resp
def get_one_visite_chiro(id_base_visit):
    try:
        result = DB.session.query(ConditionsVisite).filter_by(
            id_base_visit=id_base_visit
        ).one()
        return _format_visite_data(result)
    except NoResultFound:
        return (
            {'err': 'visite introuvable', 'id_base_visit': id_base_visit},
            404
        )


@blueprint.route('/visite', defaults={'id_visite': None}, methods=['POST', 'PUT'])
@blueprint.route('/visite/<id_visite>', methods=['POST', 'PUT'])
@json_resp
def create_or_update_visite_chiro(id_visite=None):
    db_sess = DB.session
    data = request.get_json()

    if not id_visite:
        id_visite = data.get('id_visite', None)

    # creation de base visite
    base_repo = GNMonitoringVisiteRepository(db_sess)
    base_visit = base_repo.handle_write(
        id_base_visite=id_visite,
        data=data
    )

    # creation condition visite
    visite = None
    id_visite_cond = (
        data['id_visite_cond'] if 'id_visite_cond' in data else None
    )
    if id_visite_cond:
        visite = db_sess.query(ConditionsVisite).get(id_visite_cond)

    if not visite:
        visite = ConditionsVisite(base_visit=base_visit)
        # db_sess.add(visite)

    db_sess.add(visite)
    db_sess.commit()

    visite.base_visit = base_visit

    # creation ajout rapide de taxons
    __taxons__ = data['__taxons__'] if '__taxons__' in data else None
    if __taxons__:
        for contact in __taxons__:
            contact['id_base_visit'] = visite.id_base_visit
            GNMonitoringContactTaxon(db_sess, contact, True).handle_write()

    return _format_visite_data(visite)


@blueprint.route('/visite/<id_visite>', methods=['DELETE'])
@json_resp
def delete_visite_chiro(id_visite):
    '''
        Suppression d'un enregistrement visite
    '''
    try:
        visite = DB.session.query(TBaseVisits).filter(
            TBaseVisits.id_base_visit == id_visite
        ).one()
    except NoResultFound:
        return {}, 404

    else:
        try:
            DB.session.delete(visite)
            DB.session.commit()
            return {'data': id_visite}
        except Exception:
            DB.session.rollback()
            return ({
                'data': id_visite,
                'errmsg': 'Erreur de suppression'
                }, 400)




